/* Kiru field suggestions.
   Shared by every page. Remembers what was typed into each field and offers it back
   as a dropdown the next time you type in a similar field (same label / name), on any page.
   - Uses event delegation, so fields created later (modals, table rows) work automatically.
   - History is stored in this browser's localStorage (key: kiru_suggest_v1).
   - Opt a field out with data-no-suggest, or autocomplete="off" on password/OTP style fields.
   - Console helpers: KiruSuggest.clear() wipes history, KiruSuggest.ENABLED = false disables. */
(function(){
  var STORE = "kiru_suggest_v1";
  var MAX_PER_FIELD = 60, MAX_SHOWN = 8, MIN_LEN = 2, MAX_LEN = 200;
  var SKIP_TYPES = /^(password|file|checkbox|radio|hidden|date|datetime-local|time|month|week|color|range|button|submit|reset|image|search)$/i;
  var SKIP_NAMES = /pass|pwd|pin\b|otp|token|secret|card|cvv|search|filter|^q$/i;

  var api = window.KiruSuggest = { ENABLED: true, clear: function(){ data = {}; save(); } };
  var data = load();

  function load(){ try{ return JSON.parse(localStorage.getItem(STORE)||"{}")||{}; }catch(e){ return {}; } }
  function save(){ try{ localStorage.setItem(STORE, JSON.stringify(data)); }catch(e){} }

  function norm(s){ return String(s||"").toLowerCase().replace(/[^a-z0-9 ]+/g," ").replace(/\s+/g," ").trim(); }

  function eligible(el){
    if(!api.ENABLED || !el || el.nodeType!==1) return false;
    var tag = el.tagName;
    if(tag!=="INPUT" && tag!=="TEXTAREA") return false;
    if(el.readOnly || el.disabled || el.hasAttribute("data-no-suggest")) return false;
    if(tag==="INPUT"){
      if(SKIP_TYPES.test(el.type||"text")) return false;
      if(el.hasAttribute("list")) return false;             // page already supplies its own list
    }
    var ac = (el.getAttribute("autocomplete")||"").toLowerCase();
    if(/password|one-time-code|cc-/.test(ac)) return false;
    if(SKIP_NAMES.test((el.name||"")+" "+(el.id||""))) return false;
    return true;
  }

  // Identify "similar" fields: by label text, else placeholder, else name/id (row numbers removed).
  function keyFor(el){
    var label = "";
    try{
      if(el.labels && el.labels.length) label = el.labels[0].textContent;
      if(!label){
        var aria = el.getAttribute("aria-label"); if(aria) label = aria;
      }
      if(!label){
        var p = el.parentElement;
        for(var i=0;i<3 && p && !label;i++, p=p.parentElement){
          var l = p.querySelector(":scope > label, :scope > .lab, :scope > .lbl, :scope > span.label");
          if(l && !l.contains(el)) label = l.textContent;
        }
      }
    }catch(e){}
    if(!label) label = el.placeholder || "";
    if(!label) label = (el.name || el.id || "").replace(/[0-9_\-\[\]]+/g," ");
    label = norm(label).slice(0,60);
    return label || null;
  }

  function record(el){
    if(!eligible(el)) return;
    var v = (el.value||"").trim();
    if(v.length<MIN_LEN || v.length>MAX_LEN || v.indexOf("\n")>=0) return;
    var k = keyFor(el); if(!k) return;
    var list = data[k] || (data[k]=[]), now = Date.now(), hit = null;
    for(var i=0;i<list.length;i++){ if(list[i].v===v){ hit=list[i]; break; } }
    if(hit){ hit.n++; hit.t=now; } else list.push({v:v,n:1,t:now});
    if(list.length>MAX_PER_FIELD){
      list.sort(function(a,b){ return (b.n*1e12+b.t)-(a.n*1e12+a.t); });  // drop least used / oldest
      list.length = MAX_PER_FIELD;
    }
    save();
  }

  function matches(el){
    var k = keyFor(el); if(!k || !data[k]) return [];
    var q = (el.value||"").trim().toLowerCase();
    return data[k].filter(function(e){
      var lv = e.v.toLowerCase();
      return lv!==q && (!q || lv.indexOf(q)>=0);
    }).sort(function(a,b){
      var ap = q && a.v.toLowerCase().indexOf(q)===0 ? 1:0, bp = q && b.v.toLowerCase().indexOf(q)===0 ? 1:0;
      return (bp-ap) || (b.n-a.n) || (b.t-a.t);
    }).slice(0,MAX_SHOWN).map(function(e){ return e.v; });
  }

  // ---- dropdown UI ----
  var box = null, cur = null, items = [], idx = -1;
  function ensureBox(){
    if(box) return box;
    var css = document.createElement("style");
    css.textContent =
      "#kiru-suggest{position:fixed;z-index:2147483000;display:none;max-height:240px;overflow:auto;background:#fff;color:#111;"+
      "border:1px solid #c9ced6;border-radius:8px;box-shadow:0 6px 20px rgba(0,0,0,.18);font:14px/1.3 system-ui,sans-serif;padding:4px 0}"+
      "#kiru-suggest div{padding:7px 12px;cursor:pointer;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}"+
      "#kiru-suggest div.on,#kiru-suggest div:hover{background:#e8f0fe}"+
      "@media (prefers-color-scheme:dark){#kiru-suggest{background:#1f2430;color:#eee;border-color:#3a4150}"+
      "#kiru-suggest div.on,#kiru-suggest div:hover{background:#2f3a52}}";
    document.head.appendChild(css);
    box = document.createElement("div"); box.id = "kiru-suggest";
    box.addEventListener("mousedown", function(e){
      e.preventDefault();                                   // keep focus in the field
      var t = e.target.closest("div"); if(t && t.parentNode===box) pick(t.textContent);
    });
    document.body.appendChild(box);
    return box;
  }
  function hide(){ if(box) box.style.display="none"; items=[]; idx=-1; }
  function place(){
    if(!box || !cur) return;
    var r = cur.getBoundingClientRect();
    box.style.left = Math.max(4,r.left)+"px";
    box.style.minWidth = Math.max(r.width,160)+"px";
    var below = window.innerHeight - r.bottom;
    if(below < 160 && r.top > below){ box.style.top="auto"; box.style.bottom=(window.innerHeight-r.top+2)+"px"; }
    else { box.style.bottom="auto"; box.style.top=(r.bottom+2)+"px"; }
  }
  function show(el){
    if(!eligible(el)){ hide(); return; }
    cur = el; items = matches(el);
    if(!items.length){ hide(); return; }
    var b = ensureBox(); b.innerHTML = "";
    items.forEach(function(v){ var d=document.createElement("div"); d.textContent=v; b.appendChild(d); });
    idx = -1; b.style.display="block"; place();
  }
  function mark(){
    if(!box) return;
    Array.prototype.forEach.call(box.children, function(c,i){ c.classList.toggle("on", i===idx); });
    if(box.children[idx]) box.children[idx].scrollIntoView({block:"nearest"});
  }
  function pick(v){
    if(!cur) return;
    var el = cur;
    el.value = v;
    el.dispatchEvent(new Event("input",{bubbles:true}));
    el.dispatchEvent(new Event("change",{bubbles:true}));
    hide();
  }

  document.addEventListener("focusin", function(e){ show(e.target); });
  document.addEventListener("input", function(e){ if(e.target===cur || eligible(e.target)) show(e.target); });
  document.addEventListener("focusout", function(e){ record(e.target); setTimeout(function(){ if(document.activeElement!==cur) hide(); },0); });
  document.addEventListener("change", function(e){ record(e.target); });
  document.addEventListener("submit", function(e){
    Array.prototype.forEach.call(e.target.elements||[], record);
  }, true);
  document.addEventListener("click", function(e){
    // Save fields when a Save/Submit style button is clicked, before the page re-renders.
    var b = e.target.closest && e.target.closest("button,input[type=button],input[type=submit]");
    if(!b) return;
    var scope = b.closest("form,.modal,[role=dialog],dialog,.card,body") || document.body;
    Array.prototype.forEach.call(scope.querySelectorAll("input,textarea"), record);
  }, true);
  document.addEventListener("keydown", function(e){
    if(!box || box.style.display!=="block" || e.target!==cur) return;
    if(e.key==="ArrowDown"){ e.preventDefault(); idx=(idx+1)%items.length; mark(); }
    else if(e.key==="ArrowUp"){ e.preventDefault(); idx=(idx-1+items.length)%items.length; mark(); }
    else if(e.key==="Enter" && idx>=0){ e.preventDefault(); pick(items[idx]); }
    else if(e.key==="Escape"){ hide(); }
  }, true);
  window.addEventListener("scroll", place, true);
  window.addEventListener("resize", place);
  window.addEventListener("storage", function(e){ if(e.key===STORE) data = load(); });
})();
