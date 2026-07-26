// ============================================================
//  MON JOURNAL ALIMENTAIRE — Logique applicative
// ============================================================
import { supabase, isConfigured } from "./supabase.js";

/* ---------- Constantes ---------- */
const MEAL_TYPES = [
  { key: "petit_dejeuner", label: "Petit-déjeuner", emoji: "🥐", bg: "bg-breakfast", time: "08:00" },
  { key: "dejeuner",       label: "Déjeuner",       emoji: "🍽️", bg: "bg-lunch",     time: "12:30" },
  { key: "diner",          label: "Dîner",          emoji: "🌙", bg: "bg-dinner",    time: "19:30" },
  { key: "encas",          label: "Encas",          emoji: "🍎", bg: "bg-snack",     time: "16:00" },
];
const DRINK_TYPES = [
  { key: "eau", label: "Eau", emoji: "💧" },
  { key: "the", label: "Thé", emoji: "🍵" },
  { key: "cafe", label: "Café", emoji: "☕" },
  { key: "sucree", label: "Sucrée", emoji: "🥤" },
  { key: "gazeuse", label: "Gazeuse", emoji: "🫧" },
  { key: "non_sucree", label: "Non sucrée", emoji: "🧃" },
];
const QTY_KINDS = [
  { key: "nombre", label: "Nombre" },
  { key: "petite", label: "Petite" },
  { key: "moyenne", label: "Moyenne" },
  { key: "grande", label: "Grande" },
];
const FEELINGS = [
  { v: 1, e: "😣", l: "Très mal" },
  { v: 2, e: "😕", l: "Mal" },
  { v: 3, e: "😐", l: "Moyen" },
  { v: 4, e: "🙂", l: "Bien" },
  { v: 5, e: "😀", l: "Très bien" },
];
const SYMPTOMS = ["Ballonnement","Lourdeur","Fatigue","Somnolence","Mal de tête","Nausée","Acidité","Faim rapide","Léger / en forme"];

/* ---------- État global ---------- */
const state = {
  user: null,
  date: todayISO(),
  tab: "journee",
  categories: [],
  productsByCat: {},
};

/* ---------- Utilitaires ---------- */
function todayISO() { const d = new Date(); return d.toISOString().slice(0, 10); }
function el(id) { return document.getElementById(id); }
function esc(s) { return (s ?? "").toString().replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c])); }
function mealMeta(key) { return MEAL_TYPES.find(m => m.key === key) || MEAL_TYPES[0]; }
function drinkMeta(key) { return DRINK_TYPES.find(d => d.key === key) || { label: key, emoji: "🥤" }; }

function fmtDateLabel(iso) {
  const d = new Date(iso + "T00:00:00");
  const t = todayISO();
  if (iso === t) return "Aujourd'hui";
  const yest = new Date(); yest.setDate(yest.getDate() - 1);
  if (iso === yest.toISOString().slice(0, 10)) return "Hier";
  return d.toLocaleDateString("fr-FR", { weekday: "short", day: "numeric", month: "short" });
}
function fmtLong(iso) {
  return new Date(iso + "T00:00:00").toLocaleDateString("fr-FR",
    { weekday: "long", day: "numeric", month: "long", year: "numeric" });
}

function toast(msg, kind = "") {
  const t = document.createElement("div");
  t.className = "toast " + kind;
  t.textContent = msg;
  el("toast-root").appendChild(t);
  setTimeout(() => { t.style.opacity = "0"; t.style.transition = "opacity .3s"; setTimeout(() => t.remove(), 300); }, 2400);
}

/* ---------- Système de modale ---------- */
function openModal(innerHTML) {
  const overlay = document.createElement("div");
  overlay.className = "modal-overlay";
  overlay.innerHTML = `<div class="modal">${innerHTML}</div>`;
  overlay.addEventListener("mousedown", e => { if (e.target === overlay) closeModal(overlay); });
  el("modal-root").appendChild(overlay);
  return overlay;
}
function closeModal(node) { node?.remove(); }

/* ============================================================
   AUTHENTIFICATION
   ============================================================ */
let authMode = "login";

function setupAuth() {
  const form = el("auth-form");
  const toggleLink = el("auth-toggle-link");
  const msg = el("auth-message");

  if (!isConfigured()) el("auth-config-warning").classList.remove("hidden");

  toggleLink.addEventListener("click", (e) => {
    e.preventDefault();
    authMode = authMode === "login" ? "signup" : "login";
    el("auth-submit").textContent = authMode === "login" ? "Se connecter" : "Créer mon compte";
    el("auth-toggle-text").textContent = authMode === "login" ? "Pas encore de compte ?" : "Déjà un compte ?";
    toggleLink.textContent = authMode === "login" ? "Créer un compte" : "Se connecter";
    el("auth-password").setAttribute("autocomplete", authMode === "login" ? "current-password" : "new-password");
    msg.textContent = "";
  });

  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    msg.className = "auth-message";
    if (!isConfigured()) { msg.textContent = "Configurez d'abord config.js."; msg.classList.add("error"); return; }
    const email = el("auth-email").value.trim();
    const password = el("auth-password").value;
    el("auth-submit").disabled = true;
    try {
      if (authMode === "login") {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
      } else {
        const { error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        msg.textContent = "Compte créé ! Vérifiez vos emails si une confirmation est demandée, puis connectez-vous.";
        msg.classList.add("ok");
      }
    } catch (err) {
      msg.textContent = translateAuthError(err.message);
      msg.classList.add("error");
    } finally {
      el("auth-submit").disabled = false;
    }
  });
}

function translateAuthError(m = "") {
  if (/invalid login/i.test(m)) return "Email ou mot de passe incorrect.";
  if (/already registered/i.test(m)) return "Un compte existe déjà avec cet email.";
  if (/6 characters/i.test(m)) return "Le mot de passe doit faire au moins 6 caractères.";
  if (/confirm/i.test(m)) return "Veuillez confirmer votre email avant de vous connecter.";
  return m || "Une erreur est survenue.";
}

async function logout() {
  await supabase.auth.signOut();
  state.user = null;
  showAuth();
}

function showAuth() { el("auth-view").classList.remove("hidden"); el("app-view").classList.add("hidden"); }
function showApp() { el("auth-view").classList.add("hidden"); el("app-view").classList.remove("hidden"); }

/* ============================================================
   CATALOGUE (catégories + produits)
   ============================================================ */
async function loadCatalog() {
  const [{ data: cats }, { data: prods }] = await Promise.all([
    supabase.from("categories").select("*").order("sort_order"),
    supabase.from("products").select("*").eq("is_active", true).order("name"),
  ]);
  state.categories = cats || [];
  state.productsByCat = {};
  for (const c of state.categories) state.productsByCat[c.id] = [];
  for (const p of (prods || [])) {
    if (!state.productsByCat[p.category_id]) state.productsByCat[p.category_id] = [];
    state.productsByCat[p.category_id].push(p);
  }
}

/* ============================================================
   CHARGEMENT D'UNE JOURNÉE
   ============================================================ */
async function loadDay(date) {
  const [meals, drinks, health, activities] = await Promise.all([
    supabase.from("meals")
      .select("*, meal_items(*, products(name,emoji))")
      .eq("meal_date", date).order("meal_time", { nullsFirst: false }),
    supabase.from("drinks").select("*").eq("log_date", date),
    supabase.from("health_states").select("*").eq("log_date", date).order("log_time"),
    supabase.from("activities").select("*").eq("activity_date", date),
  ]);
  return {
    meals: meals.data || [],
    drinks: drinks.data || [],
    health: health.data || [],
    activities: activities.data || [],
  };
}

/* ============================================================
   ONGLET « JOURNÉE »
   ============================================================ */
async function renderJournee() {
  const panel = el("tab-journee");
  panel.innerHTML = `<p class="empty-hint">Chargement…</p>`;
  const day = await loadDay(state.date);

  const nbAliments = day.meals.reduce((s, m) => s + (m.meal_items?.length || 0), 0);
  const nbVerres = day.drinks.reduce((s, d) => s + Number(d.glasses || 0), 0);
  const calBrulees = day.activities.reduce((s, a) => s + (a.calories || 0), 0);

  let html = `
    <div class="day-summary">
      <div class="stat-tile"><div class="v">${nbAliments}</div><div class="l">aliments</div></div>
      <div class="stat-tile"><div class="v">${nbVerres}</div><div class="l">verres bus</div></div>
      <div class="stat-tile"><div class="v">${calBrulees || "–"}</div><div class="l">kcal dépensées</div></div>
    </div>`;

  // Cartes repas
  for (const mt of MEAL_TYPES) {
    const meal = day.meals.find(m => m.meal_type === mt.key);
    const items = meal?.meal_items || [];
    const mealDrinks = day.drinks.filter(d => d.meal_id === meal?.id);

    html += `<div class="meal-card">
      <div class="meal-card-head">
        <div class="meal-title">
          <span class="meal-emoji ${mt.bg}">${mt.emoji}</span>
          <div>${mt.label}
            <div class="meal-time">${meal
              ? `🕐 <input type="time" value="${meal.meal_time || ""}" data-meal-time="${meal.id}">`
              : `<span class="muted">non renseigné</span>`}</div>
          </div>
        </div>
        <button class="btn btn-soft btn-sm" data-add-item="${mt.key}">+ Aliment</button>
      </div>`;

    if (items.length) {
      html += `<ul class="item-list">` + items.map(it => {
        const name = it.products?.name || it.custom_name || "Aliment";
        const emo = it.products?.emoji || "🍴";
        const qty = it.quantity_kind === "nombre"
          ? `× ${it.quantity_number ?? 1}`
          : cap(it.quantity_kind);
        return `<li class="item-row">
          <span class="item-main">${emo} ${esc(name)}</span>
          <span style="display:flex;align-items:center;gap:8px">
            <span class="item-qty">${qty}</span>
            <button class="item-del" data-del-item="${it.id}">✕</button>
          </span></li>`;
      }).join("") + `</ul>`;
    } else {
      html += `<p class="empty-hint">Rien pour l'instant.</p>`;
    }

    // Boissons rattachées au repas
    if (mealDrinks.length) {
      html += `<div class="pill-row">` + mealDrinks.map(d => {
        const dm = drinkMeta(d.drink_type);
        return `<span class="pill">${dm.emoji} ${dm.label} · ${d.glasses} verre${d.glasses > 1 ? "s" : ""}
          <span class="x" data-del-drink="${d.id}">✕</span></span>`;
      }).join("") + `</div>`;
    }
    html += `<div class="add-line"><button class="btn btn-sm" data-add-drink="${mt.key}">🥤 Ajouter une boisson</button></div>`;
    html += `</div>`;
  }

  // Boissons libres (hors repas)
  const freeDrinks = day.drinks.filter(d => !d.meal_id);
  if (freeDrinks.length) {
    html += `<div class="meal-card">
      <div class="meal-title" style="margin-bottom:6px"><span class="meal-emoji bg-snack">💧</span> Hydratation (hors repas)</div>
      <div class="pill-row">` + freeDrinks.map(d => {
        const dm = drinkMeta(d.drink_type);
        return `<span class="pill">${dm.emoji} ${dm.label} · ${d.glasses}
          <span class="x" data-del-drink="${d.id}">✕</span></span>`;
      }).join("") + `</div></div>`;
  }

  // Activités
  html += `<div class="section-title" style="margin-top:6px">🏃 Activités <span class="count">${day.activities.length}</span></div>`;
  html += `<div class="meal-card">`;
  if (day.activities.length) {
    html += `<div class="pill-row">` + day.activities.map(a =>
      `<span class="pill act">🔥 ${esc(a.name)}${a.duration_min ? " · " + a.duration_min + " min" : ""}${a.calories ? " · " + a.calories + " kcal" : ""}
        <span class="x" data-del-act="${a.id}">✕</span></span>`).join("") + `</div>`;
  } else {
    html += `<p class="empty-hint">Aucune activité enregistrée ce jour.</p>`;
  }
  html += `<div class="add-line"><button class="btn btn-sm" id="add-activity">🏃 Ajouter une activité</button></div></div>`;

  panel.innerHTML = html;
  wireJourneeEvents();
}

function cap(s) { return s ? s[0].toUpperCase() + s.slice(1) : s; }

function wireJourneeEvents() {
  const panel = el("tab-journee");
  panel.querySelectorAll("[data-add-item]").forEach(b =>
    b.onclick = () => openAddItemModal(b.dataset.addItem));
  panel.querySelectorAll("[data-add-drink]").forEach(b =>
    b.onclick = () => openAddDrinkModal(b.dataset.addDrink));
  panel.querySelectorAll("[data-del-item]").forEach(b =>
    b.onclick = () => delRow("meal_items", b.dataset.delItem));
  panel.querySelectorAll("[data-del-drink]").forEach(b =>
    b.onclick = () => delRow("drinks", b.dataset.delDrink));
  panel.querySelectorAll("[data-del-act]").forEach(b =>
    b.onclick = () => delRow("activities", b.dataset.delAct));
  panel.querySelectorAll("[data-meal-time]").forEach(inp =>
    inp.onchange = async () => {
      await supabase.from("meals").update({ meal_time: inp.value }).eq("id", inp.dataset.mealTime);
      toast("Heure mise à jour", "ok");
    });
  const act = el("add-activity");
  if (act) act.onclick = openAddActivityModal;
}

async function delRow(table, id) {
  const { error } = await supabase.from(table).delete().eq("id", id);
  if (error) return toast("Suppression impossible", "err");
  toast("Supprimé");
  renderJournee();
}

/* ---------- Récupère (ou crée) le repas du jour ---------- */
async function ensureMeal(mealTypeKey) {
  const { data: existing } = await supabase.from("meals")
    .select("id").eq("meal_date", state.date).eq("meal_type", mealTypeKey).maybeSingle();
  if (existing) return existing.id;
  const meta = mealMeta(mealTypeKey);
  const { data, error } = await supabase.from("meals")
    .insert({ meal_date: state.date, meal_type: mealTypeKey, meal_time: meta.time })
    .select("id").single();
  if (error) { toast("Erreur création repas", "err"); throw error; }
  return data.id;
}

/* ============================================================
   MODALE : AJOUTER UN ALIMENT
   ============================================================ */
function openAddItemModal(mealTypeKey) {
  const meta = mealMeta(mealTypeKey);
  let activeCat = state.categories[0]?.id;
  // Sélection multiple : clé -> { product_id, name, emoji, quantity_kind, quantity_number }
  const selected = new Map();
  let customSeq = 0;

  const overlay = openModal(`
    <div class="modal-head"><h2>${meta.emoji} ${meta.label} · aliments</h2>
      <button class="modal-close">✕</button></div>
    <p class="pick-hint">Touchez les aliments pour en choisir <b>plusieurs</b> (même dans différentes catégories).</p>
    <div class="cat-tabs" id="cat-tabs"></div>
    <div class="product-grid" id="product-grid"></div>
    <div class="field" style="margin-top:8px"><label>… ou ajouter un aliment libre</label>
      <div class="custom-row">
        <input type="text" id="custom-name" placeholder="Ex : Tarte aux pommes maison" />
        <button class="btn btn-soft" id="add-custom" type="button">+ Ajouter</button>
      </div>
    </div>
    <div id="tray" class="tray"></div>
    <button class="btn btn-primary btn-block" id="save-item" disabled>Ajouter</button>
  `);

  const catTabs = overlay.querySelector("#cat-tabs");
  const grid = overlay.querySelector("#product-grid");
  const tray = overlay.querySelector("#tray");
  const customInput = overlay.querySelector("#custom-name");
  const saveBtn = overlay.querySelector("#save-item");

  catTabs.innerHTML = state.categories.map(c =>
    `<button class="cat-tab ${c.id === activeCat ? "active" : ""}" data-cat="${c.id}">${c.emoji} ${esc(c.name)}</button>`).join("");

  function renderProducts() {
    const list = state.productsByCat[activeCat] || [];
    grid.innerHTML = list.length ? list.map(p =>
      `<button class="product-btn ${selected.has(p.id) ? "selected" : ""}" data-prod="${p.id}" data-emoji="${p.emoji || "🍴"}" data-name="${esc(p.name)}">
        <span class="pe">${p.emoji || "🍴"}</span>${esc(p.name)}
        ${selected.has(p.id) ? '<span class="pick-check">✓</span>' : ""}</button>`).join("")
      : `<p class="empty-hint">Aucun produit. Ajoutez-en dans Réglages.</p>`;
    grid.querySelectorAll("[data-prod]").forEach(b => b.onclick = () => {
      const id = b.dataset.prod;
      if (selected.has(id)) selected.delete(id);
      else selected.set(id, { product_id: id, name: b.dataset.name, emoji: b.dataset.emoji, quantity_kind: "moyenne", quantity_number: null });
      renderProducts();
      renderTray();
    });
  }

  function renderTray() {
    const entries = [...selected.entries()];
    saveBtn.disabled = entries.length === 0;
    saveBtn.textContent = entries.length
      ? `Ajouter ${entries.length} aliment${entries.length > 1 ? "s" : ""}`
      : "Ajouter";
    if (!entries.length) { tray.innerHTML = ""; return; }
    tray.innerHTML = `<div class="tray-count">Sélection (${entries.length}) — précisez la quantité :</div>` +
      entries.map(([key, it]) => `
        <div class="tray-item" data-key="${key}">
          <span class="tname">${it.emoji} ${esc(it.name)}</span>
          <select class="tray-kind">
            ${QTY_KINDS.map(q => `<option value="${q.key}" ${q.key === it.quantity_kind ? "selected" : ""}>${q.label}</option>`).join("")}
          </select>
          <input type="number" class="tray-num" placeholder="Nb" step="0.5" min="0"
            value="${it.quantity_number ?? ""}" style="${it.quantity_kind === "nombre" ? "" : "display:none"}">
          <button class="rm" title="Retirer">✕</button>
        </div>`).join("");
    tray.querySelectorAll(".tray-item").forEach(row => {
      const key = row.dataset.key;
      const it = selected.get(key);
      row.querySelector(".tray-kind").onchange = (e) => {
        it.quantity_kind = e.target.value;
        row.querySelector(".tray-num").style.display = e.target.value === "nombre" ? "" : "none";
      };
      row.querySelector(".tray-num").oninput = (e) => { it.quantity_number = e.target.value ? Number(e.target.value) : null; };
      row.querySelector(".rm").onclick = () => {
        selected.delete(key);
        renderProducts();
        renderTray();
      };
    });
  }

  renderProducts();
  renderTray();

  catTabs.querySelectorAll("[data-cat]").forEach(b => b.onclick = () => {
    activeCat = b.dataset.cat;
    catTabs.querySelectorAll(".cat-tab").forEach(x => x.classList.remove("active"));
    b.classList.add("active");
    renderProducts();
  });

  function addCustom() {
    const v = customInput.value.trim();
    if (!v) return;
    selected.set("custom:" + (++customSeq), { product_id: null, name: v, emoji: "🍴", quantity_kind: "moyenne", quantity_number: null });
    customInput.value = "";
    renderTray();
  }
  overlay.querySelector("#add-custom").onclick = addCustom;
  customInput.onkeydown = (e) => { if (e.key === "Enter") { e.preventDefault(); addCustom(); } };
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);

  saveBtn.onclick = async () => {
    const entries = [...selected.values()];
    if (!entries.length) return;
    saveBtn.disabled = true;
    try {
      const mealId = await ensureMeal(mealTypeKey);
      const rows = entries.map(it => ({
        meal_id: mealId,
        product_id: it.product_id,
        custom_name: it.product_id ? null : it.name,
        quantity_kind: it.quantity_kind,
        quantity_number: it.quantity_kind === "nombre" ? (it.quantity_number || 1) : null,
      }));
      const { error } = await supabase.from("meal_items").insert(rows);
      if (error) throw error;
      closeModal(overlay);
      toast(`${rows.length} aliment${rows.length > 1 ? "s" : ""} ajouté${rows.length > 1 ? "s" : ""}`, "ok");
      renderJournee();
    } catch (e) { toast("Erreur : " + e.message, "err"); saveBtn.disabled = false; }
  };
}

/* ============================================================
   MODALE : AJOUTER UNE BOISSON
   ============================================================ */
function openAddDrinkModal(mealTypeKey) {
  let type = "eau", glasses = 1;
  const overlay = openModal(`
    <div class="modal-head"><h2>🥤 Boisson</h2><button class="modal-close">✕</button></div>
    <div class="field"><label>Type de boisson</label>
      <div class="chip-row" id="drink-types"></div></div>
    <div class="field"><label>Nombre de verres</label>
      <input type="number" id="glasses" value="1" min="0.5" step="0.5" /></div>
    <button class="btn btn-primary btn-block" id="save-drink">Ajouter</button>
  `);
  const dt = overlay.querySelector("#drink-types");
  dt.innerHTML = DRINK_TYPES.map(d =>
    `<button class="chip ${d.key === "eau" ? "selected" : ""}" data-d="${d.key}">${d.emoji} ${d.label}</button>`).join("");
  dt.querySelectorAll("[data-d]").forEach(b => b.onclick = () => {
    type = b.dataset.d;
    dt.querySelectorAll(".chip").forEach(x => x.classList.remove("selected"));
    b.classList.add("selected");
  });
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);
  overlay.querySelector("#save-drink").onclick = async () => {
    glasses = Number(overlay.querySelector("#glasses").value || 1);
    try {
      const mealId = mealTypeKey ? await ensureMeal(mealTypeKey) : null;
      const { error } = await supabase.from("drinks")
        .insert({ meal_id: mealId, log_date: state.date, drink_type: type, glasses });
      if (error) throw error;
      closeModal(overlay); toast("Boisson ajoutée", "ok"); renderJournee();
    } catch (e) { toast("Erreur : " + e.message, "err"); }
  };
}

/* ============================================================
   MODALE : AJOUTER UNE ACTIVITÉ
   ============================================================ */
function openAddActivityModal() {
  let intensity = "moderee";
  const overlay = openModal(`
    <div class="modal-head"><h2>🏃 Activité physique</h2><button class="modal-close">✕</button></div>
    <div class="field"><label>Activité</label>
      <input type="text" id="act-name" placeholder="Ex : Marche, Vélo, Musculation…" /></div>
    <div class="field"><label>Durée (minutes)</label>
      <input type="number" id="act-dur" placeholder="30" min="0" /></div>
    <div class="field"><label>Intensité</label>
      <div class="chip-row" id="act-int">
        <button class="chip" data-i="faible">🟢 Faible</button>
        <button class="chip selected" data-i="moderee">🟡 Modérée</button>
        <button class="chip" data-i="intense">🔴 Intense</button>
      </div></div>
    <div class="field"><label>Calories dépensées (optionnel)</label>
      <input type="number" id="act-cal" placeholder="Estimation en kcal" min="0" /></div>
    <button class="btn btn-primary btn-block" id="save-act">Ajouter</button>
  `);
  const ai = overlay.querySelector("#act-int");
  ai.querySelectorAll("[data-i]").forEach(b => b.onclick = () => {
    intensity = b.dataset.i;
    ai.querySelectorAll(".chip").forEach(x => x.classList.remove("selected"));
    b.classList.add("selected");
  });
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);
  overlay.querySelector("#save-act").onclick = async () => {
    const name = overlay.querySelector("#act-name").value.trim();
    if (!name) return toast("Indiquez l'activité", "err");
    const row = {
      activity_date: state.date, name, intensity,
      duration_min: Number(overlay.querySelector("#act-dur").value) || null,
      calories: Number(overlay.querySelector("#act-cal").value) || null,
    };
    const { error } = await supabase.from("activities").insert(row);
    if (error) return toast("Erreur : " + error.message, "err");
    closeModal(overlay); toast("Activité ajoutée", "ok"); renderJournee();
  };
}

/* ============================================================
   MODALE : ÉTAT DE SANTÉ / BIEN-ÊTRE
   ============================================================ */
async function openHealthModal() {
  let feeling = 3;
  const chosenSymptoms = new Set();
  // Repas du jour pour rattacher l'observation
  const { data: meals } = await supabase.from("meals")
    .select("id, meal_type, meal_time").eq("meal_date", state.date);
  const mealOptions = (meals || []).map(m =>
    `<option value="${m.id}">${mealMeta(m.meal_type).label}${m.meal_time ? " (" + m.meal_time.slice(0,5) + ")" : ""}</option>`).join("");

  const now = new Date().toTimeString().slice(0, 5);
  const overlay = openModal(`
    <div class="modal-head"><h2>💚 Comment vous sentez-vous ?</h2><button class="modal-close">✕</button></div>
    <div class="field"><label>Ressenti général</label>
      <div class="feeling-row" id="feeling-row">
        ${FEELINGS.map(f => `<button class="feeling-opt ${f.v === 3 ? "selected" : ""}" data-f="${f.v}">${f.e}<span class="fl">${f.l}</span></button>`).join("")}
      </div></div>
    <div class="field"><label>Après quel repas ? (optionnel)</label>
      <select id="h-meal"><option value="">— Aucun / général —</option>${mealOptions}</select></div>
    <div class="field" style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
      <div><label>Heure de l'observation</label><input type="time" id="h-time" value="${now}"></div>
      <div><label>Combien d'heures après le repas ?</label><input type="number" id="h-hours" placeholder="ex : 2" min="0" step="0.5"></div>
    </div>
    <div class="field"><label>Ressentis / symptômes</label>
      <div class="chip-row" id="symptom-row">
        ${SYMPTOMS.map(s => `<button class="chip" data-s="${esc(s)}">${esc(s)}</button>`).join("")}
      </div></div>
    <div class="field"><label>Description libre</label>
      <textarea id="h-desc" placeholder="Décrivez comment vous vous sentez, digestion, énergie…"></textarea></div>
    <button class="btn btn-primary btn-block" id="save-health">Enregistrer</button>
  `);

  const fr = overlay.querySelector("#feeling-row");
  fr.querySelectorAll("[data-f]").forEach(b => b.onclick = () => {
    feeling = Number(b.dataset.f);
    fr.querySelectorAll(".feeling-opt").forEach(x => x.classList.remove("selected"));
    b.classList.add("selected");
  });
  const sr = overlay.querySelector("#symptom-row");
  sr.querySelectorAll("[data-s]").forEach(b => b.onclick = () => {
    const s = b.dataset.s;
    if (chosenSymptoms.has(s)) { chosenSymptoms.delete(s); b.classList.remove("selected"); }
    else { chosenSymptoms.add(s); b.classList.add("selected"); }
  });
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);
  overlay.querySelector("#save-health").onclick = async () => {
    const row = {
      log_date: state.date,
      meal_id: overlay.querySelector("#h-meal").value || null,
      log_time: overlay.querySelector("#h-time").value || null,
      hours_after: Number(overlay.querySelector("#h-hours").value) || null,
      feeling,
      symptoms: [...chosenSymptoms],
      description: overlay.querySelector("#h-desc").value.trim() || null,
    };
    const { error } = await supabase.from("health_states").insert(row);
    if (error) return toast("Erreur : " + error.message, "err");
    closeModal(overlay); toast("Bien-être enregistré", "ok"); renderBienetre();
  };
}

/* ============================================================
   ONGLET « BIEN-ÊTRE »
   ============================================================ */
async function renderBienetre() {
  const panel = el("tab-bienetre");
  panel.innerHTML = `<p class="empty-hint">Chargement…</p>`;
  const { data } = await supabase.from("health_states")
    .select("*").eq("log_date", state.date).order("log_time", { nullsFirst: false });

  let html = `<div class="section-title">💚 Bien-être du jour</div>
    <button class="btn btn-primary btn-block" id="new-health" style="margin-bottom:16px">+ Noter mon état de santé</button>`;

  if (!data || !data.length) {
    html += `<div class="meal-card"><p class="empty-hint">Aucune observation pour ${fmtDateLabel(state.date).toLowerCase()}.
      Notez comment vous vous sentez après vos repas pour repérer ce qui vous réussit… ou pas.</p></div>`;
  } else {
    for (const h of data) {
      const f = FEELINGS.find(x => x.v === h.feeling) || FEELINGS[2];
      html += `<div class="meal-card">
        <div class="meal-card-head">
          <div class="meal-title"><span class="meal-emoji bg-snack" style="font-size:24px">${f.e}</span>
            <div>${f.l}<div class="meal-time">
              ${h.log_time ? "🕐 " + h.log_time.slice(0,5) : ""}${h.hours_after ? " · " + h.hours_after + "h après repas" : ""}</div></div>
          </div>
          <button class="item-del" data-del-health="${h.id}">✕</button>
        </div>
        ${h.symptoms?.length ? `<div class="pill-row">${h.symptoms.map(s => `<span class="pill act">${esc(s)}</span>`).join("")}</div>` : ""}
        ${h.description ? `<p class="history-line" style="margin-top:10px">${esc(h.description)}</p>` : ""}
      </div>`;
    }
  }
  panel.innerHTML = html;
  el("new-health").onclick = openHealthModal;
  panel.querySelectorAll("[data-del-health]").forEach(b =>
    b.onclick = async () => { await supabase.from("health_states").delete().eq("id", b.dataset.delHealth); toast("Supprimé"); renderBienetre(); });
}

/* ============================================================
   ONGLET « HISTORIQUE » (7 derniers jours)
   ============================================================ */
async function renderHistorique() {
  const panel = el("tab-historique");
  panel.innerHTML = `<p class="empty-hint">Chargement…</p>`;
  const since = new Date(); since.setDate(since.getDate() - 13);
  const sinceISO = since.toISOString().slice(0, 10);

  const [meals, drinks, health, acts] = await Promise.all([
    supabase.from("meals").select("meal_date, meal_type, meal_items(id)").gte("meal_date", sinceISO),
    supabase.from("drinks").select("log_date, glasses").gte("log_date", sinceISO),
    supabase.from("health_states").select("log_date, feeling").gte("log_date", sinceISO),
    supabase.from("activities").select("activity_date, name").gte("activity_date", sinceISO),
  ]);

  const days = {};
  const touch = d => (days[d] ??= { aliments: 0, verres: 0, feelings: [], acts: 0 });
  (meals.data || []).forEach(m => touch(m.meal_date).aliments += (m.meal_items?.length || 0));
  (drinks.data || []).forEach(d => touch(d.log_date).verres += Number(d.glasses || 0));
  (health.data || []).forEach(h => { if (h.feeling) touch(h.log_date).feelings.push(h.feeling); });
  (acts.data || []).forEach(a => touch(a.activity_date).acts += 1);

  const sortedDays = Object.keys(days).sort().reverse();
  let html = `<div class="section-title">📖 14 derniers jours</div>`;
  if (!sortedDays.length) {
    html += `<div class="meal-card"><p class="empty-hint">Pas encore d'historique. Commencez à saisir vos repas !</p></div>`;
  } else {
    for (const d of sortedDays) {
      const s = days[d];
      const avgFeel = s.feelings.length ? (s.feelings.reduce((a, b) => a + b, 0) / s.feelings.length) : null;
      const fe = avgFeel ? (FEELINGS.find(x => x.v === Math.round(avgFeel))?.e || "") : "";
      html += `<div class="history-day" data-goto="${d}" style="cursor:pointer">
        <h3>${fmtDateLabel(d) === "Aujourd'hui" || fmtDateLabel(d) === "Hier" ? fmtDateLabel(d) : fmtLong(d)}</h3>
        <div class="history-line">🍴 <b>${s.aliments}</b> aliments · 💧 <b>${s.verres}</b> verres · 🏃 <b>${s.acts}</b> activité(s) ${fe ? "· ressenti " + fe : ""}</div>
      </div>`;
    }
  }
  panel.innerHTML = html;
  panel.querySelectorAll("[data-goto]").forEach(c => c.onclick = () => {
    state.date = c.dataset.goto;
    syncDateUI();
    switchTab("journee");
  });
}

/* ============================================================
   ONGLET « RÉGLAGES »
   ============================================================ */
async function renderReglages() {
  const panel = el("tab-reglages");
  const email = state.user?.email || "";
  const totalProd = Object.values(state.productsByCat).reduce((s, a) => s + a.length, 0);
  panel.innerHTML = `
    <div class="settings-card">
      <h3>👤 Mon compte</h3>
      <div class="settings-row"><span class="muted">Email</span><span>${esc(email)}</span></div>
      <div class="settings-row"><span class="muted">Sécurité</span><span>🔒 Données privées (RLS)</span></div>
      <div class="settings-row"><span></span><button class="btn btn-danger btn-sm" id="logout-btn">Se déconnecter</button></div>
    </div>

    <div class="settings-card">
      <h3>🥗 Mes produits</h3>
      <div class="settings-row"><span class="muted">${totalProd} produits dans ${state.categories.length} catégories</span>
        <button class="btn btn-soft btn-sm" id="add-product">+ Ajouter</button></div>
      <p class="muted" style="margin-top:8px">Ajoutez vos aliments préférés pour les retrouver rapidement lors de la saisie.</p>
    </div>

    <div class="settings-card">
      <h3>📊 Analyses (à venir)</h3>
      <p class="muted">La version 2 croisera vos repas et votre bien-être pour identifier
      les aliments à éviter, ceux qui vous réussissent, et votre progression.</p>
    </div>

    <div class="settings-card">
      <h3>📱 Installer l'application</h3>
      <p class="muted">Sur iPhone : bouton Partager → « Sur l'écran d'accueil ».<br>
      Sur ordinateur : icône d'installation dans la barre d'adresse.</p>
    </div>

    <div class="version-badge">Version ${window.APP_CONFIG?.APP_VERSION || "1.0.0"} · Mon Journal Alimentaire</div>
  `;
  el("logout-btn").onclick = logout;
  el("add-product").onclick = openAddProductModal;
}

function openAddProductModal() {
  let cat = state.categories[0]?.id;
  const overlay = openModal(`
    <div class="modal-head"><h2>➕ Nouveau produit</h2><button class="modal-close">✕</button></div>
    <div class="field"><label>Catégorie</label>
      <select id="p-cat">${state.categories.map(c => `<option value="${c.id}">${c.emoji} ${esc(c.name)}</option>`).join("")}</select></div>
    <div class="field"><label>Nom du produit</label><input type="text" id="p-name" placeholder="Ex : Houmous"></div>
    <div class="field"><label>Emoji (optionnel)</label><input type="text" id="p-emoji" placeholder="🥙" maxlength="4"></div>
    <button class="btn btn-primary btn-block" id="save-product">Ajouter à mon catalogue</button>
  `);
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);
  overlay.querySelector("#save-product").onclick = async () => {
    const name = overlay.querySelector("#p-name").value.trim();
    cat = overlay.querySelector("#p-cat").value;
    if (!name) return toast("Indiquez un nom", "err");
    const { error } = await supabase.from("products").insert({
      category_id: cat, name, emoji: overlay.querySelector("#p-emoji").value.trim() || null,
      user_id: state.user.id,
    });
    if (error) return toast("Erreur : " + error.message, "err");
    closeModal(overlay); toast("Produit ajouté", "ok");
    await loadCatalog(); renderReglages();
  };
}

/* ============================================================
   NAVIGATION
   ============================================================ */
function switchTab(tab) {
  state.tab = tab;
  document.querySelectorAll(".tab-btn").forEach(b => b.classList.toggle("active", b.dataset.tab === tab));
  document.querySelectorAll(".tab-panel").forEach(p => p.classList.remove("active"));
  el("tab-" + tab).classList.add("active");
  if (tab === "journee") renderJournee();
  if (tab === "historique") renderHistorique();
  if (tab === "bienetre") renderBienetre();
  if (tab === "reglages") renderReglages();
}

function syncDateUI() {
  el("current-date-label").textContent = fmtDateLabel(state.date);
  el("current-date").value = state.date;
}
function shiftDate(days) {
  const d = new Date(state.date + "T00:00:00");
  d.setDate(d.getDate() + days);
  state.date = d.toISOString().slice(0, 10);
  syncDateUI();
  if (state.tab === "journee") renderJournee();
  if (state.tab === "bienetre") renderBienetre();
}

function setupNav() {
  document.querySelectorAll(".tab-btn").forEach(b => b.onclick = () => switchTab(b.dataset.tab));
  el("day-prev").onclick = () => shiftDate(-1);
  el("day-next").onclick = () => shiftDate(1);
  el("today-btn").onclick = () => { state.date = todayISO(); syncDateUI(); switchTab(state.tab); };
  el("current-date").onchange = (e) => { state.date = e.target.value; syncDateUI(); switchTab(state.tab); };

  // Bouton flottant : ajout rapide du bien-être
  const fab = document.createElement("button");
  fab.className = "fab"; fab.textContent = "💚"; fab.title = "Noter mon bien-être";
  fab.onclick = openHealthModal;
  el("app-view").appendChild(fab);
}

/* ============================================================
   DÉMARRAGE
   ============================================================ */
async function boot() {
  setupAuth();

  if (isConfigured()) {
    const { data } = await supabase.auth.getSession();
    if (data.session) {
      state.user = data.session.user;
      await startApp();
    } else {
      showAuth();
    }
    supabase.auth.onAuthStateChange(async (_e, session) => {
      if (session?.user && !state.user) { state.user = session.user; await startApp(); }
      if (!session) { state.user = null; showAuth(); }
    });
  } else {
    showAuth();
  }
}

async function startApp() {
  showApp();
  syncDateUI();
  setupNav();
  await loadCatalog();
  switchTab("journee");
}

boot();
