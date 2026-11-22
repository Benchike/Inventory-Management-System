/* Alerts for tasks that someone has assigned to you.
   Loaded by the dashboard and the Task Management page.
   - A pop-up alarm (with a short sound and, if allowed, a desktop notification) appears for new assignments.
   - A bell icon (#taskBell, with a count badge in #taskBellN) shows how many assigned tasks you have not acknowledged yet,
     so it is visible the moment you sign in. Pressing "Got it" or "Open" acknowledges them.
   Needs add_task_management.sql (column tasks.assign_ack_at). Without it this quietly does nothing.
   Usage: KiruTaskAlerts.start(supabaseClient, user)                                              */
(function(){
  var SB=null, ME=null, started=false, busy=false, box=null, popped={};
  try{ popped=JSON.parse(sessionStorage.getItem("kiru_ta_popped")||"{}"); }catch(e){}

  function el(tag,css,text){ var e=document.createElement(tag); if(css) e.style.cssText=css; if(text!=null) e.textContent=text; return e; }
  function remember(){ try{ sessionStorage.setItem("kiru_ta_popped",JSON.stringify(popped)); }catch(e){} }

  function beep(){
    try{
      var AC=window.AudioContext||window.webkitAudioContext; if(!AC) return;
      var ctx=new AC(), t=ctx.currentTime;
      [880,660,880].forEach(function(f,i){
        var o=ctx.createOscillator(), g=ctx.createGain();
        o.type="sine"; o.frequency.value=f; o.connect(g); g.connect(ctx.destination);
        g.gain.setValueAtTime(0.0001,t+i*0.22); g.gain.exponentialRampToValueAtTime(0.25,t+i*0.22+0.03); g.gain.exponentialRampToValueAtTime(0.0001,t+i*0.22+0.2);
        o.start(t+i*0.22); o.stop(t+i*0.22+0.21);
      });
      setTimeout(function(){ try{ ctx.close(); }catch(e){} },1200);
    }catch(e){}
  }

  function setBell(n){
    var b=document.getElementById("taskBell"), c=document.getElementById("taskBellN");
    if(!b) return;
    b.style.display="";
    if(c){ c.textContent=n>99?"99+":String(n); c.style.display=n?"":"none"; }
    b.classList.toggle("ring",n>0);
    b.title=n?(n+" new task"+(n===1?"":"s")+" assigned to you"):"Task Management";
  }

  function style(){
    if(document.getElementById("taStyle")) return;
    var s=document.createElement("style"); s.id="taStyle";
    s.textContent="@keyframes taPulse{0%,100%{box-shadow:0 18px 40px -16px rgba(2,20,49,.5),0 0 0 0 rgba(0,164,255,.55)}50%{box-shadow:0 18px 40px -16px rgba(2,20,49,.5),0 0 0 9px rgba(0,164,255,0)}}"+
      "@keyframes taRing{0%,100%{transform:rotate(0)}10%,30%,50%{transform:rotate(-14deg)}20%,40%,60%{transform:rotate(14deg)}70%{transform:rotate(0)}}"+
      "#taskBell.ring svg{animation:taRing 1.6s ease-in-out 3}";
    document.head.appendChild(s);
  }

  function ensureBox(){
    if(box && document.body.contains(box)) return box;
    box=el("div","position:fixed;left:50%;top:84px;transform:translateX(-50%);z-index:100002;display:flex;flex-direction:column;gap:10px;width:min(420px,calc(100vw - 28px))");
    document.body.appendChild(box);
    return box;
  }
  function btn(label,primary){
    return el("button","font:inherit;font-size:12.5px;font-weight:700;cursor:pointer;border-radius:9px;padding:8px 13px;border:1px solid "+(primary?"#00a4ff":"#c9d3e0")+";background:"+(primary?"#00a4ff":"#fff")+";color:"+(primary?"#04121f":"#021431"),label);
  }
  function fmtDue(d){ if(!d) return ""; try{ return new Date(d+"T00:00:00").toLocaleDateString("en-GB",{day:"numeric",month:"short",year:"numeric"}); }catch(e){ return d; } }

  async function ack(ids){
    if(!ids.length) return;
    await SB.from("tasks").update({assign_ack_at:new Date().toISOString()}).in("id",ids);
    refresh(false);
  }

  function popup(list,names){
    style();
    var ids=list.map(function(t){ return t.id; });
    var card=el("div","background:#fff;color:#021431;border:1px solid #e3e9f1;border-top:5px solid #00a4ff;border-radius:14px;padding:16px 18px;font-family:'Plus Jakarta Sans',system-ui,sans-serif;animation:taPulse 1.4s ease-in-out 4");
    card.setAttribute("role","alertdialog");
    card.appendChild(el("div","font-size:11px;font-weight:800;letter-spacing:.09em;text-transform:uppercase;color:#0086d4;margin-bottom:6px","🔔 "+(list.length===1?"New task assigned to you":list.length+" new tasks assigned to you")));
    list.slice(0,4).forEach(function(t){
      var row=el("div","padding:7px 0;border-top:1px solid #eef2f7");
      row.appendChild(el("div","font-size:14px;font-weight:700;line-height:1.35",t.title||"Untitled task"));
      var from=names[t.created_by_id]||(t.created_by||"").split("@")[0]||"a manager";
      var bits=["From "+from,t.priority?t.priority+" priority":"",t.due_date?"Due "+fmtDue(t.due_date):""].filter(Boolean);
      row.appendChild(el("div","font-size:12px;color:#56657a;margin-top:2px",bits.join(" · ")));
      card.appendChild(row);
    });
    if(list.length>4) card.appendChild(el("div","font-size:12px;color:#56657a;padding-top:7px;border-top:1px solid #eef2f7","+ "+(list.length-4)+" more"));
    var row=el("div","display:flex;gap:8px;margin-top:12px;justify-content:flex-end");
    var got=btn("Got it"), open=btn("Open Task Management",true);
    got.onclick=function(){ card.remove(); ack(ids); };
    open.onclick=function(){ ack(ids).then(function(){}); card.remove(); if(/task-tracker/.test(location.pathname)) location.reload(); else location.href="task-tracker.html"; };
    row.appendChild(got); row.appendChild(open); card.appendChild(row);
    ensureBox().appendChild(card);
    beep();
    try{
      if("Notification" in window && Notification.permission==="granted"){
        var n=new Notification(list.length===1?"New task: "+(list[0].title||""):list.length+" new tasks assigned to you",{body:"Open Kiru Task Management to view",tag:"kiru-task-assign"});
        n.onclick=function(){ window.focus(); n.close(); };
      }
    }catch(e){}
  }

  async function refresh(allowPopup){
    if(!SB||!ME||busy) return; busy=true;
    try{
      var r=await SB.from("tasks").select("id,title,priority,due_date,created_by,created_by_id,status")
        .eq("assignee_id",ME).is("assign_ack_at",null).neq("created_by_id",ME).neq("status","Done").order("created_at");
      if(r.error){ return; }                       // migration not run yet
      var list=r.data||[];
      setBell(list.length);
      if(allowPopup){
        var fresh=list.filter(function(t){ return !popped[t.id]; });
        if(fresh.length){
          fresh.forEach(function(t){ popped[t.id]=1; }); remember();
          var cids=[]; fresh.forEach(function(t){ if(t.created_by_id && cids.indexOf(t.created_by_id)<0) cids.push(t.created_by_id); });
          var names={};
          if(cids.length){
            var m=await SB.from("team_members").select("user_id,full_name,email").in("user_id",cids);
            (m.data||[]).forEach(function(x){ names[x.user_id]=(x.full_name||"").trim()||(x.email||"").split("@")[0]; });
          }
          popup(fresh,names);
        }
      }
    }catch(e){ console.error("task alert check failed",e); }
    finally{ busy=false; }
  }

  window.KiruTaskAlerts={
    start:function(client,user){
      SB=client; ME=user&&user.id; if(!ME) return;
      if(started){ refresh(true); return; }
      started=true;
      style();
      refresh(true);
      setInterval(function(){ refresh(true); },30000);
      document.addEventListener("visibilitychange",function(){ if(!document.hidden) refresh(true); });
    },
    refresh:function(){ return refresh(true); }
  };
})();
