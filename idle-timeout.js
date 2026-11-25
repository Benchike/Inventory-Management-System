/* Kiru auto sign-out after 30 minutes of inactivity  +  "pick up where you left off".
   Shared by every page. Activity on any open Kiru tab counts, because the last-activity
   time lives in localStorage (same origin as the Supabase session).

   Resume: while a page is open its form fields (and, if the page registers a hook, its
   own state such as an open editor) are kept in localStorage for the signed-in user.
   If the user is signed out for being idle, the next sign-in sends them straight back to
   that page and puts everything back as it was. A manual "Sign out" discards it.
   Pages can opt in to more control:
     KiruResume.manual = true;                      // page will call KiruResume.restore() itself once its data is loaded
     KiruResume.hook = { get: fn()->object, set: fn(object) };   // extra state, e.g. which editor is open
*/
(function(){
  var LIMIT = 30*60*1000;
  var WARN  = 60*1000;                 // show a countdown banner for the last minute
  var ENABLED = true;                  // master switch for auto sign-out
  var KEY = "kiru_last_activity";
  var NOTE = "kiru_idle_signed_out";
  var RKEY = "kiru_resume_v1";         // saved page state
  var PEND = "kiru_resume_pending";    // user id signed out for idleness, waiting to resume
  var GO   = "kiru_resume_go";         // page the next load should restore
  var MAXAGE = 3*24*3600*1000;

  function tokenKey(){
    try{
      for(var i=0;i<localStorage.length;i++){
        var k=localStorage.key(i);
        if(k && /^sb-.*-auth-token$/.test(k)) return k;
      }
    }catch(e){}
    return null;
  }
  function hasSession(){ return !!tokenKey(); }
  function userId(){
    try{
      var k=tokenKey(); if(!k) return null;
      var v=JSON.parse(localStorage.getItem(k)||"null");
      return (v && ((v.user && v.user.id) || (v.currentSession && v.currentSession.user && v.currentSession.user.id))) || null;
    }catch(e){ return null; }
  }
  function last(){ try{ return parseInt(localStorage.getItem(KEY)||"0",10)||0; }catch(e){ return 0; } }
  function touch(){ try{ localStorage.setItem(KEY,String(Date.now())); }catch(e){} }

  /* ---------------- resume: save ---------------- */
  var path = location.pathname + location.search;
  var isHome = /(^|\/)(index(\.html)?)?$/.test(location.pathname);
  var armed = true, localAct = Date.now(), saveTimer = null;
  var R = { manual:false, hook:null };

  function skipEl(el){
    var t=(el.type||"").toLowerCase();
    return t==="password"||t==="file"||t==="button"||t==="submit"||t==="reset"||t==="image"||t==="hidden"||
           el.hasAttribute("data-noresume") || (el.closest && el.closest("[data-noresume]"));
  }
  function keyFor(el,i){
    var t=(el.type||"").toLowerCase();
    if(t==="radio" && el.name) return "r:"+el.name;
    if(el.id) return "#"+el.id;
    if(el.name) return "n:"+el.name;
    return "i:"+i;
  }
  function snapshot(){
    var out={}, els=document.querySelectorAll("input,textarea,select");
    for(var i=0;i<els.length;i++){
      var el=els[i]; if(skipEl(el)) continue;
      var t=(el.type||"").toLowerCase(), k=keyFor(el,i);
      if(t==="radio"){ if(el.checked) out[k]=el.value; else if(!(k in out)) out[k]=null; continue; }
      if(t==="checkbox"){ out[k]=!!el.checked; continue; }
      var v=el.value;
      if(typeof v==="string" && v.length>200000) continue;   // don't store huge pasted/embedded blobs
      out[k]=v;
    }
    return out;
  }
  function readStore(){ try{ return JSON.parse(localStorage.getItem(RKEY)||"null"); }catch(e){ return null; } }
  function save(force){
    if(isHome || (!armed && !force)) return;
    if(restoring && !restoredOnce) return;               // never overwrite the saved state before it has been put back
    var uid=userId(); if(!uid) return;
    var cur=readStore();
    // another tab was used more recently: let it keep the slot
    if(cur && cur.uid===uid && cur.path!==path && cur.t>localAct) return;
    var rec={uid:uid, path:path, t:localAct, scrollY:window.scrollY||0, fields:snapshot(), custom:null};
    try{ if(R.hook && R.hook.get) rec.custom=R.hook.get(); }catch(e){}
    try{ localStorage.setItem(RKEY,JSON.stringify(rec)); }catch(e){}
  }
  function queueSave(){ if(saveTimer) return; saveTimer=setTimeout(function(){ saveTimer=null; save(); },1500); }

  /* ---------------- resume: restore ---------------- */
  var restoring=false, pendingKeys=null, touched={}, obs=null, restoredSnap=null;
  (function(){
    try{
      var go=localStorage.getItem(GO), st=readStore();
      if(go && go===path && st && st.path===path && st.uid===userId() && Date.now()-st.t<MAXAGE){
        restoring=true; armed=false; restoredSnap=st;
      }
      if(go && go===path) localStorage.removeItem(GO);
    }catch(e){}
  })();

  function setField(el,v){
    var t=(el.type||"").toLowerCase();
    if(t==="checkbox"){ if(el.checked===!!v) return true; el.checked=!!v; }
    else if(t==="radio"){ return true; }
    else { if(el.value===v) return true; el.value=v; if(el.value!==v) return false; }
    el.dispatchEvent(new Event("input",{bubbles:true}));
    el.dispatchEvent(new Event("change",{bubbles:true}));
    return true;
  }
  function elFor(k,list){
    if(k.charAt(0)==="#") return document.getElementById(k.slice(1));
    if(k.slice(0,2)==="n:") return document.querySelector('[name="'+k.slice(2).replace(/"/g,'\\"')+'"]');
    if(k.slice(0,2)==="i:") return list[parseInt(k.slice(2),10)];
    return null;
  }
  function applyPending(){
    if(!pendingKeys) return;
    var list=document.querySelectorAll("input,textarea,select"), left=0;
    Object.keys(pendingKeys).forEach(function(k){
      if(touched[k]){ delete pendingKeys[k]; return; }
      var v=pendingKeys[k];
      if(k.slice(0,2)==="r:"){
        var rs=document.querySelectorAll('input[type=radio][name="'+k.slice(2)+'"]');
        if(!rs.length){ left++; return; }
        if(v==null){ delete pendingKeys[k]; return; }
        for(var i=0;i<rs.length;i++){ if(rs[i].value===v && !rs[i].checked){ rs[i].checked=true; rs[i].dispatchEvent(new Event("change",{bubbles:true})); } }
        delete pendingKeys[k]; return;
      }
      var el=elFor(k,list);
      if(!el){ left++; return; }
      if(setField(el,v)) delete pendingKeys[k]; else left++;
    });
    if(!left && obs){ obs.disconnect(); obs=null; }
  }
  function toast(msg){
    try{
      var d=document.createElement("div");
      d.textContent=msg;
      d.style.cssText="position:fixed;left:50%;bottom:22px;transform:translateX(-50%);z-index:100000;background:#021431;color:#fff;font:600 13px 'Plus Jakarta Sans',system-ui,sans-serif;padding:11px 18px;border-radius:12px;box-shadow:0 14px 34px -12px rgba(2,20,49,.6);max-width:90vw";
      document.body.appendChild(d);
      setTimeout(function(){ d.style.transition="opacity .5s"; d.style.opacity="0"; setTimeout(function(){ d.remove(); },600); },5000);
    }catch(e){}
  }
  var restoredOnce=false;
  function restore(){
    if(!restoring || restoredOnce) return; restoredOnce=true;
    var st=restoredSnap;
    try{ if(R.hook && R.hook.set && st.custom!=null) R.hook.set(st.custom); }catch(e){ console.error("resume hook",e); }
    pendingKeys=Object.assign({},st.fields||{});
    applyPending();
    try{ obs=new MutationObserver(applyPending); obs.observe(document.documentElement,{childList:true,subtree:true}); }catch(e){}
    setTimeout(function(){ if(obs){ obs.disconnect(); obs=null; } },10000);
    if(st.scrollY) setTimeout(function(){ window.scrollTo(0,st.scrollY); },300);
    armed=true; save(true);
    toast("Welcome back — your work was restored where you left off.");
  }
  if(restoring){
    var kick=function(){ setTimeout(function(){ if(!R.manual) restore(); },1800); };
    if(document.readyState==="complete") kick(); else window.addEventListener("load",kick);
  }

  /* ---------------- activity + sign-out ---------------- */
  var out=false, warnEl=null;
  function showWarn(sec){
    if(!warnEl){
      warnEl=document.createElement("div");
      warnEl.style.cssText="position:fixed;top:14px;left:50%;transform:translateX(-50%);z-index:100001;background:#fff3dd;color:#6b3f00;border:1px solid #e08a1e;font:700 13px 'Plus Jakarta Sans',system-ui,sans-serif;padding:11px 18px;border-radius:12px;box-shadow:0 14px 34px -12px rgba(2,20,49,.4);max-width:92vw;text-align:center";
      (document.body||document.documentElement).appendChild(warnEl);
    }
    warnEl.textContent="You will be signed out in "+sec+"s because of inactivity. Move the mouse or press a key to stay signed in. Your work is saved.";
  }
  function hideWarn(){ if(warnEl){ warnEl.remove(); warnEl=null; } }

  async function logout(){
    if(out) return; out=true;
    hideWarn();
    var uid=userId(), stamp=last();
    save(true);                                         // keep exactly what is on screen
    try{ if(uid) localStorage.setItem(PEND,uid+"|"+stamp); }catch(e){}
    try{ sessionStorage.setItem(NOTE,"1"); }catch(e){}
    try{ localStorage.setItem(NOTE,"1"); }catch(e){}
    try{ if(typeof SB!=="undefined" && SB) await SB.auth.signOut({scope:"local"}); }catch(e){}
    try{
      // make sure the stored session is gone even if signOut could not reach Supabase
      Object.keys(localStorage).forEach(function(k){ if(/^sb-.*-auth-token$/.test(k)) localStorage.removeItem(k); });
      localStorage.removeItem(KEY);
    }catch(e){}
    if(isHome) location.reload(); else location.href="/";
  }

  function check(){
    if(!ENABLED) return;
    if(!hasSession()){ hideWarn(); return; }
    var l=last();
    if(!l){ touch(); return; }            // session without a stamp: start counting now
    var idle=Date.now()-l;
    if(idle > LIMIT){ logout(); return; }
    if(idle > LIMIT-WARN) showWarn(Math.max(1,Math.ceil((LIMIT-idle)/1000))); else hideWarn();
  }

  var lastWrite=0;
  function onActivity(e){
    var n=Date.now();
    localAct=n;
    if(e && e.isTrusted && (e.type==="input"||e.type==="change") && e.target){
      var els=document.querySelectorAll("input,textarea,select"), i=Array.prototype.indexOf.call(els,e.target);
      if(i>=0) touched[keyFor(e.target,i)]=1;
    }
    if(warnEl){ touch(); hideWarn(); }
    if(n-lastWrite<5000) return;
    lastWrite=n;
    if(hasSession()) touch();
  }
  ["mousemove","mousedown","keydown","scroll","touchstart","click","wheel"].forEach(function(ev){
    window.addEventListener(ev,onActivity,{passive:true,capture:true});
  });
  ["input","change"].forEach(function(ev){
    document.addEventListener(ev,function(e){ onActivity(e); queueSave(); },true);
  });
  document.addEventListener("visibilitychange",function(){ if(document.hidden) save(); else check(); });
  window.addEventListener("pagehide",function(){ save(); });
  window.addEventListener("beforeunload",function(){ save(); });
  window.addEventListener("focus",check);
  setInterval(check,5000);
  setInterval(function(){ save(); },20000);
  check();
  if(!isHome && !restoring) setTimeout(function(){ if(hasSession()) save(); },3000);

  /* ---------------- public API ---------------- */
  function maybeResume(user){
    // called by the home page right after sign-in: go back to where the idle sign-out interrupted
    try{
      var pend=localStorage.getItem(PEND); localStorage.removeItem(PEND);
      var st=readStore();
      var parts=(pend||"").split("|"), stamp=parseInt(parts[1]||"0",10)||0;
      if(!pend || !user || parts[0]!==user.id || !st || st.uid!==user.id || !st.path) return false;
      if(Date.now()-st.t>MAXAGE) return false;
      if(stamp-st.t>120000) return false;          // the user was busy elsewhere (e.g. the dashboard) after that page
      localStorage.setItem(GO,st.path);
      location.replace(st.path);
      return true;
    }catch(e){ return false; }
  }
  function clear(){ try{ localStorage.removeItem(RKEY); localStorage.removeItem(PEND); localStorage.removeItem(GO); }catch(e){} }
  function hasSaved(){ var s=readStore(); return !!(s && s.uid===userId() && s.path && !isHome); }

  R.restore=restore; R.save=function(){ save(true); }; R.clear=clear; R.maybeResume=maybeResume; R.hasSaved=hasSaved;
  window.KiruResume=R;

  window.KiruIdle={
    touch:touch,
    limitMinutes:LIMIT/60000,
    // true once, if the user was just signed out for being idle (used to show a message on the login page)
    consumeNotice:function(){
      var v=false;
      try{ v=!!(sessionStorage.getItem(NOTE)||localStorage.getItem(NOTE)); sessionStorage.removeItem(NOTE); localStorage.removeItem(NOTE); }catch(e){}
      return v;
    }
  };
})();
