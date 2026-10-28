/* Kiru auto sign-out after 15 minutes of inactivity.
   Shared by every page: activity on any open Kiru tab/page counts, because the
   last-activity time lives in localStorage (same origin as the Supabase session). */
(function(){
  var LIMIT = 15*60*1000;
  var KEY = "kiru_last_activity";
  var NOTE = "kiru_idle_signed_out";

  function hasSession(){
    try{
      for(var i=0;i<localStorage.length;i++){
        var k=localStorage.key(i);
        if(k && /^sb-.*-auth-token$/.test(k)) return true;
      }
    }catch(e){}
    return false;
  }
  function last(){ try{ return parseInt(localStorage.getItem(KEY)||"0",10)||0; }catch(e){ return 0; } }
  function touch(){ try{ localStorage.setItem(KEY,String(Date.now())); }catch(e){} }

  var out=false;
  async function logout(){
    if(out) return; out=true;
    try{ sessionStorage.setItem(NOTE,"1"); }catch(e){}
    try{ localStorage.setItem(NOTE,"1"); }catch(e){}
    try{ if(typeof SB!=="undefined" && SB) await SB.auth.signOut({scope:"local"}); }catch(e){}
    try{
      // make sure the stored session is gone even if signOut could not reach Supabase
      Object.keys(localStorage).forEach(function(k){ if(/^sb-.*-auth-token$/.test(k)) localStorage.removeItem(k); });
      localStorage.removeItem(KEY);
    }catch(e){}
    var onIndex = /(^|\/)(index(\.html)?)?$/.test(location.pathname);
    if(onIndex) location.reload(); else location.href="/";
  }

  function check(){
    if(!hasSession()) return;
    var l=last();
    if(!l){ touch(); return; }            // session without a stamp: start counting now
    if(Date.now()-l > LIMIT) logout();
  }

  var lastWrite=0;
  function onActivity(){
    var n=Date.now();
    if(n-lastWrite<5000) return;
    lastWrite=n;
    if(hasSession()) touch();
  }
  ["mousemove","mousedown","keydown","scroll","touchstart","click","wheel"].forEach(function(ev){
    window.addEventListener(ev,onActivity,{passive:true,capture:true});
  });
  document.addEventListener("visibilitychange",function(){ if(!document.hidden) check(); });
  window.addEventListener("focus",check);
  setInterval(check,15000);
  check();

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
