/* Reminder alerts for Notes & Reminders.
   Loaded by the home page and the Notes page. While either is open in a browser tab it
   checks every 30 seconds for notes whose reminder time has passed, then shows an
   on-screen alert (and a desktop notification if the user allowed them).
   Reminders cannot fire while the app is closed — they show up the next time it is opened.
   Usage:  KiruReminders.start(supabaseClient, { onChange: function(){ ... } })           */
(function(){
  var SB = null, opts = {}, started = false, box = null, busy = false;
  var SNOOZE_MIN = 10;

  function el(tag, css, text){
    var e = document.createElement(tag);
    if(css) e.style.cssText = css;
    if(text != null) e.textContent = text;
    return e;
  }
  function ensureBox(){
    if(box && document.body.contains(box)) return box;
    box = el("div", "position:fixed;right:16px;bottom:16px;z-index:99999;display:flex;flex-direction:column;gap:10px;max-width:min(360px,calc(100vw - 32px))");
    document.body.appendChild(box);
    return box;
  }
  function changed(){ try{ if(opts.onChange) opts.onChange(); }catch(e){} }

  function btn(label, primary){
    var b = el("button",
      "font:inherit;font-size:12px;font-weight:700;cursor:pointer;border-radius:8px;padding:7px 11px;border:1px solid " +
      (primary ? "#00a4ff" : "#c9d3e0") + ";background:" + (primary ? "#00a4ff" : "#fff") + ";color:" + (primary ? "#04121f" : "#021431"), label);
    return b;
  }

  function toast(n){
    var card = el("div", "background:#fff;color:#021431;border:1px solid #e3e9f1;border-left:4px solid #e08a1e;border-radius:12px;padding:13px 14px;box-shadow:0 18px 40px -16px rgba(2,20,49,.45);font-family:'Plus Jakarta Sans',system-ui,sans-serif");
    card.appendChild(el("div", "font-size:11px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:#b06a12;margin-bottom:4px", "🔔 Reminder"));
    card.appendChild(el("div", "font-size:14px;font-weight:700;line-height:1.35;margin-bottom:3px", n.title || "Untitled note"));
    if(n.body){
      var snip = n.body.length > 140 ? n.body.slice(0, 140) + "…" : n.body;
      card.appendChild(el("div", "font-size:12.5px;color:#56657a;line-height:1.45;margin-bottom:6px;white-space:pre-wrap", snip));
    }
    var row = el("div", "display:flex;flex-wrap:wrap;gap:6px;margin-top:8px");
    var open = btn("Open", true), snooze = btn("Snooze " + SNOOZE_MIN + " min"), done = btn("Done"), close = btn("✕");
    open.onclick = function(){ window.open("notes.html", "_blank", "noopener"); };
    close.onclick = function(){ card.remove(); };
    snooze.onclick = async function(){
      snooze.disabled = true;
      await SB.from("user_notes").update({
        remind_at: new Date(Date.now() + SNOOZE_MIN * 60000).toISOString(), reminded: false, updated_at: new Date().toISOString()
      }).eq("id", n.id);
      card.remove(); changed();
    };
    done.onclick = async function(){
      done.disabled = true;
      await SB.from("user_notes").update({ done: true, updated_at: new Date().toISOString() }).eq("id", n.id);
      card.remove(); changed();
    };
    [open, snooze, done, close].forEach(function(b){ row.appendChild(b); });
    card.appendChild(row);
    ensureBox().appendChild(card);
  }

  function desktop(n){
    try{
      if(!("Notification" in window) || Notification.permission !== "granted") return;
      var x = new Notification("Reminder: " + (n.title || "Untitled note"), { body: (n.body || "").slice(0, 120), tag: n.id });
      x.onclick = function(){ window.focus(); x.close(); };
    }catch(e){}
  }

  async function check(){
    if(!SB || busy) return;
    busy = true;
    try{
      var r = await SB.from("user_notes")
        .select("id,title,body,remind_at")
        .eq("done", false).eq("reminded", false)
        .not("remind_at", "is", null).lte("remind_at", new Date().toISOString())
        .order("remind_at").limit(20);
      if(r.error || !r.data || !r.data.length) return;   // also covers "table not created yet"
      var any = false;
      for(var i = 0; i < r.data.length; i++){
        var n = r.data[i];
        // claim the reminder so two open tabs do not both alert for the same note
        var c = await SB.from("user_notes").update({ reminded: true }).eq("id", n.id).eq("reminded", false).select("id");
        if(c.data && c.data.length){ toast(n); desktop(n); any = true; }
      }
      if(any) changed();
    }catch(e){ console.error("reminder check failed", e); }
    finally{ busy = false; }
  }

  window.KiruReminders = {
    start: function(client, o){
      SB = client; opts = o || {};
      if(started) return;
      started = true;
      check();
      setInterval(check, 30000);
      document.addEventListener("visibilitychange", function(){ if(!document.hidden) check(); });
    }
  };
})();
