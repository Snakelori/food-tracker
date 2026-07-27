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
const STATS_PERIODS = [{ k: 7, l: "7 jours" }, { k: 30, l: "30 jours" }, { k: 90, l: "90 jours" }, { k: 0, l: "Tout" }];

/* ---------- État global ---------- */
const state = {
  user: null,
  date: todayISO(),
  tab: "journee",
  categories: [],
  productsByCat: {},
  statsPeriod: 30,
};

/* ---------- Utilitaires ---------- */
// Date locale au format YYYY-MM-DD (JAMAIS toISOString, qui renvoie l'UTC et décale d'un jour la nuit)
function toISODate(d) {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
function todayISO() { return toISODate(new Date()); }
function dateDaysAgo(n) { const d = new Date(); d.setDate(d.getDate() - n); return toISODate(d); }
function average(arr) { return arr.length ? arr.reduce((a, b) => a + b, 0) / arr.length : 0; }
function feelColor(v) { return v >= 4 ? "var(--green)" : v >= 3 ? "var(--lemon)" : v >= 2 ? "var(--peach)" : "var(--danger)"; }

/* Nutrition : facteur de quantité et calcul par portion */
const QTY_FACTOR = { petite: 0.6, moyenne: 1, grande: 1.5 };
function qtyFactor(kind, number) { return kind === "nombre" ? (Number(number) || 1) : (QTY_FACTOR[kind] ?? 1); }
function nutriFromProduct(prod, kind, number) {
  if (!prod || prod.energy_kcal == null || prod.portion_g == null) return null;
  const grams = prod.portion_g * qtyFactor(kind, number);
  const f = grams / 100;
  return {
    grams,
    kcal: (prod.energy_kcal || 0) * f, carb: (prod.carb_g || 0) * f,
    sugar: (prod.sugar_g || 0) * f, fat: (prod.fat_g || 0) * f,
    prot: (prod.protein_g || 0) * f, salt: (prod.salt_g || 0) * f,
  };
}
function itemNutrition(item) { return nutriFromProduct(item.products, item.quantity_kind, item.quantity_number); }
function portionKcal(p) { return (p.energy_kcal == null || p.portion_g == null) ? null : Math.round(p.energy_kcal * p.portion_g / 100); }
function addNutri(a, b) { if (!b) return a; for (const k of ["kcal", "carb", "sugar", "fat", "prot", "salt"]) a[k] += b[k]; return a; }
function emptyNutri() { return { kcal: 0, carb: 0, sugar: 0, fat: 0, prot: 0, salt: 0 }; }
const r0 = n => Math.round(n);
const r1 = n => Math.round(n * 10) / 10;
function el(id) { return document.getElementById(id); }
function esc(s) { return (s ?? "").toString().replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c])); }
function mealMeta(key) { return MEAL_TYPES.find(m => m.key === key) || MEAL_TYPES[0]; }
function drinkMeta(key) { return DRINK_TYPES.find(d => d.key === key) || { label: key, emoji: "🥤" }; }

function fmtDateLabel(iso) {
  const d = new Date(iso + "T00:00:00");
  const t = todayISO();
  if (iso === t) return "Aujourd'hui";
  const yest = new Date(); yest.setDate(yest.getDate() - 1);
  if (iso === toISODate(yest)) return "Hier";
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
      .select("*, meal_items(*, products(name,emoji,energy_kcal,carb_g,sugar_g,fat_g,protein_g,salt_g,portion_g))")
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

  // Totaux nutritionnels du jour (aliments reconnus du catalogue)
  const dayNutri = emptyNutri();
  for (const m of day.meals) for (const it of (m.meal_items || [])) addNutri(dayNutri, itemNutrition(it));

  let html = `
    <div class="day-summary">
      <div class="stat-tile"><div class="v">${r0(dayNutri.kcal) || "–"}</div><div class="l">kcal ingérées</div></div>
      <div class="stat-tile"><div class="v">${r0(dayNutri.sugar) || "–"}<span class="u">g</span></div><div class="l">sucre</div></div>
      <div class="stat-tile"><div class="v">${r0(dayNutri.fat) || "–"}<span class="u">g</span></div><div class="l">mat. grasses</div></div>
      <div class="stat-tile"><div class="v">${nbAliments}</div><div class="l">aliments</div></div>
      <div class="stat-tile"><div class="v">${r1(nbVerres)}</div><div class="l">verres bus</div></div>
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
            <button class="item-edit" data-edit-item="${it.id}" title="Modifier">✏️</button>
            <button class="item-del" data-del-item="${it.id}">✕</button>
          </span></li>`;
      }).join("") + `</ul>`;
    } else {
      html += `<p class="empty-hint">Rien pour l'instant.</p>`;
    }

    // Totaux nutritionnels du repas
    const mealNutri = emptyNutri();
    for (const it of items) addNutri(mealNutri, itemNutrition(it));
    if (mealNutri.kcal > 0) {
      html += `<div class="meal-nutri">🔥 ${r0(mealNutri.kcal)} kcal · 🍬 ${r1(mealNutri.sugar)} g · 🧈 ${r1(mealNutri.fat)} g · 🥩 ${r1(mealNutri.prot)} g prot.</div>`;
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

  // Édition d'un aliment déjà saisi (quantité)
  const itemsById = {};
  for (const m of day.meals) for (const it of (m.meal_items || [])) itemsById[it.id] = it;
  panel.querySelectorAll("[data-edit-item]").forEach(b =>
    b.onclick = () => openEditItemModal(itemsById[b.dataset.editItem]));
}

function cap(s) { return s ? s[0].toUpperCase() + s.slice(1) : s; }

/* ---------- Modale : modifier un aliment d'un repas ---------- */
function openEditItemModal(item) {
  if (!item) return;
  const name = item.products?.name || item.custom_name || "Aliment";
  const emoji = item.products?.emoji || "🍴";
  let kind = item.quantity_kind, number = item.quantity_number;

  const overlay = openModal(`
    <div class="modal-head"><h2>✏️ ${emoji} ${esc(name)}</h2><button class="modal-close">✕</button></div>
    <div class="field"><label>Quantité</label>
      <div class="qty-grid" id="e-qty"></div>
      <input type="number" id="e-num" placeholder="Nombre (ex : 2)" step="0.5" min="0"
        value="${number ?? ""}" style="margin-top:8px;${kind === "nombre" ? "" : "display:none"}">
    </div>
    <div id="e-nutri" class="tray-nutri" style="margin-bottom:14px"></div>
    <button class="btn btn-primary btn-block" id="e-save">Enregistrer</button>
    <button class="btn btn-danger btn-block" id="e-del" style="margin-top:8px">🗑️ Retirer du repas</button>
  `);
  const qtyGrid = overlay.querySelector("#e-qty");
  const numInput = overlay.querySelector("#e-num");
  const nutriEl = overlay.querySelector("#e-nutri");
  qtyGrid.innerHTML = QTY_KINDS.map(q =>
    `<button class="qty-opt ${q.key === kind ? "selected" : ""}" data-q="${q.key}">${q.label}</button>`).join("");

  const refreshNutri = () => {
    const n = item.products ? nutriFromProduct(item.products, kind, number) : null;
    nutriEl.innerHTML = n ? `🔥 ${r0(n.kcal)} kcal · 🍬 ${r1(n.sugar)} g · 🧈 ${r1(n.fat)} g` : "";
  };
  refreshNutri();

  qtyGrid.querySelectorAll("[data-q]").forEach(b => b.onclick = () => {
    kind = b.dataset.q;
    qtyGrid.querySelectorAll(".qty-opt").forEach(x => x.classList.remove("selected"));
    b.classList.add("selected");
    numInput.style.display = kind === "nombre" ? "" : "none";
    refreshNutri();
  });
  numInput.oninput = () => { number = numInput.value ? Number(numInput.value) : null; refreshNutri(); };
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);

  overlay.querySelector("#e-save").onclick = async () => {
    const { error } = await supabase.from("meal_items").update({
      quantity_kind: kind,
      quantity_number: kind === "nombre" ? (number || 1) : null,
    }).eq("id", item.id);
    if (error) return toast("Erreur : " + error.message, "err");
    closeModal(overlay); toast("Aliment modifié", "ok"); renderJournee();
  };
  overlay.querySelector("#e-del").onclick = async () => {
    const { error } = await supabase.from("meal_items").delete().eq("id", item.id);
    if (error) return toast("Erreur : " + error.message, "err");
    closeModal(overlay); toast("Supprimé"); renderJournee();
  };
}

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
async function openAddItemModal(mealTypeKey) {
  const meta = mealMeta(mealTypeKey);
  let activeCat = state.categories[0]?.id;
  // Sélection multiple : clé -> { product_id, name, emoji, quantity_kind, quantity_number }
  const selected = new Map();
  let customSeq = 0;

  // Heure : reprend l'heure du repas s'il existe, sinon défaut (heure actuelle pour un encas)
  const { data: existingMeal } = await supabase.from("meals")
    .select("meal_time").eq("meal_date", state.date).eq("meal_type", mealTypeKey).maybeSingle();
  const defaultTime = existingMeal?.meal_time
    ? existingMeal.meal_time.slice(0, 5)
    : (mealTypeKey === "encas" ? new Date().toTimeString().slice(0, 5) : meta.time);

  const overlay = openModal(`
    <div class="modal-head"><h2>${meta.emoji} ${meta.label} · aliments</h2>
      <button class="modal-close">✕</button></div>
    <div class="field time-field"><label>🕐 Heure de prise</label>
      <input type="time" id="item-time" value="${defaultTime}"></div>
    <p class="pick-hint">Touchez les aliments pour en choisir <b>plusieurs</b> (recherche ou navigation par catégorie).</p>
    <input type="text" id="prod-search" class="prod-search" placeholder="🔍 Rechercher un aliment (toutes catégories)…" />
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
  const searchInput = overlay.querySelector("#prod-search");

  // Index de tous les produits (pour la nutrition au clic + la recherche globale)
  const prodById = new Map();
  const allProducts = [];
  const catName = id => state.categories.find(c => c.id === id)?.name || "";
  for (const c of state.categories) for (const p of (state.productsByCat[c.id] || [])) {
    prodById.set(p.id, p);
    allProducts.push({ ...p, _cat: c.name });
  }

  catTabs.innerHTML = state.categories.map(c =>
    `<button class="cat-tab ${c.id === activeCat ? "active" : ""}" data-cat="${c.id}">${c.emoji} ${esc(c.name)}</button>`).join("");

  function renderProducts() {
    const q = searchInput.value.trim().toLowerCase();
    const searching = q.length > 0;
    catTabs.style.display = searching ? "none" : "";           // masque les onglets pendant la recherche
    const list = searching
      ? allProducts.filter(p => p.name.toLowerCase().includes(q)).slice(0, 60)
      : (state.productsByCat[activeCat] || []);
    grid.innerHTML = list.length ? list.map(p => {
      const kc = portionKcal(p);
      return `<button class="product-btn ${selected.has(p.id) ? "selected" : ""}" data-prod="${p.id}">
        <span class="pe">${p.emoji || "🍴"}</span>${esc(p.name)}
        ${searching && p._cat ? `<span class="pcat">${esc(p._cat)}</span>` : ""}
        ${kc != null ? `<span class="pkcal">${kc} kcal</span>` : ""}
        ${selected.has(p.id) ? '<span class="pick-check">✓</span>' : ""}</button>`;
    }).join("")
      : `<p class="empty-hint">${searching ? "Aucun aliment trouvé pour « " + esc(q) + " »." : "Aucun produit. Ajoutez-en dans Réglages."}</p>`;
    grid.querySelectorAll("[data-prod]").forEach(b => b.onclick = () => {
      const id = b.dataset.prod;
      if (selected.has(id)) selected.delete(id);
      else {
        const p = prodById.get(id);
        selected.set(id, { product_id: id, name: p.name, emoji: p.emoji || "🍴", prod: p, quantity_kind: "moyenne", quantity_number: null });
      }
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
    const nutriLine = it => {
      const n = it.prod ? nutriFromProduct(it.prod, it.quantity_kind, it.quantity_number) : null;
      return n ? `<div class="tray-nutri">🔥 ${r0(n.kcal)} kcal · 🍬 ${r1(n.sugar)} g · 🧈 ${r1(n.fat)} g</div>` : "";
    };
    tray.innerHTML = `<div class="tray-count">Sélection (${entries.length}) — précisez la quantité :</div>` +
      entries.map(([key, it]) => `
        <div class="tray-item" data-key="${key}">
          <div class="tray-line">
            <span class="tname">${it.emoji} ${esc(it.name)}</span>
            <select class="tray-kind">
              ${QTY_KINDS.map(q => `<option value="${q.key}" ${q.key === it.quantity_kind ? "selected" : ""}>${q.label}</option>`).join("")}
            </select>
            <input type="number" class="tray-num" placeholder="Nb" step="0.5" min="0"
              value="${it.quantity_number ?? ""}" style="${it.quantity_kind === "nombre" ? "" : "display:none"}">
            <button class="rm" title="Retirer">✕</button>
          </div>
          <div class="tray-nutri-slot">${nutriLine(it)}</div>
        </div>`).join("");
    tray.querySelectorAll(".tray-item").forEach(row => {
      const key = row.dataset.key;
      const it = selected.get(key);
      const refreshNutri = () => { row.querySelector(".tray-nutri-slot").innerHTML = nutriLine(it); };
      row.querySelector(".tray-kind").onchange = (e) => {
        it.quantity_kind = e.target.value;
        row.querySelector(".tray-num").style.display = e.target.value === "nombre" ? "" : "none";
        refreshNutri();
      };
      row.querySelector(".tray-num").oninput = (e) => { it.quantity_number = e.target.value ? Number(e.target.value) : null; refreshNutri(); };
      row.querySelector(".rm").onclick = () => {
        selected.delete(key);
        renderProducts();
        renderTray();
      };
    });
  }

  renderProducts();
  renderTray();

  searchInput.oninput = renderProducts;

  catTabs.querySelectorAll("[data-cat]").forEach(b => b.onclick = () => {
    activeCat = b.dataset.cat;
    searchInput.value = "";                     // choisir une catégorie annule la recherche
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
      // Enregistre l'heure de prise indiquée
      const t = overlay.querySelector("#item-time").value;
      if (t) await supabase.from("meals").update({ meal_time: t }).eq("id", mealId);
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
  const sinceISO = toISODate(since);

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
   ONGLET « ANALYSES » — tableau de bord statistiques
   ============================================================ */
async function renderAnalyses() {
  const panel = el("tab-analyses");
  const period = state.statsPeriod ?? 30;
  const from = period === 0 ? "2000-01-01" : dateDaysAgo(period);

  panel.innerHTML = `
    <div class="section-title">📊 Analyses</div>
    <div class="cat-tabs" id="stats-period">
      ${STATS_PERIODS.map(p => `<button class="cat-tab ${p.k === period ? "active" : ""}" data-p="${p.k}">${p.l}</button>`).join("")}
    </div>
    <div id="stats-body"><p class="empty-hint">Calcul en cours…</p></div>`;
  panel.querySelectorAll("#stats-period [data-p]").forEach(b =>
    b.onclick = () => { state.statsPeriod = Number(b.dataset.p); renderAnalyses(); });

  const [mealsRes, healthRes, drinksRes, actsRes] = await Promise.all([
    supabase.from("meals").select("id, meal_date, meal_items(custom_name, quantity_kind, quantity_number, products(name,emoji,category_id,energy_kcal,carb_g,sugar_g,fat_g,protein_g,salt_g,portion_g))").gte("meal_date", from),
    supabase.from("health_states").select("meal_id, log_date, feeling, symptoms").gte("log_date", from),
    supabase.from("drinks").select("drink_type, glasses, log_date").gte("log_date", from),
    supabase.from("activities").select("activity_date, duration_min, calories").gte("activity_date", from),
  ]);
  const meals = mealsRes.data || [], health = healthRes.data || [], drinks = drinksRes.data || [], acts = actsRes.data || [];

  const catName = id => state.categories.find(c => c.id === id)?.name || null;
  const itemInfo = it => it.products
    ? { name: it.products.name, emoji: it.products.emoji || "🍴", cat: catName(it.products.category_id) }
    : { name: it.custom_name || "Aliment", emoji: "🍴", cat: null };

  // Index des repas et fréquences
  const mealById = {}, productsByDate = {};
  const foodFreq = new Map(), catFreq = new Map();
  const daysSet = new Set();
  let totalItems = 0;
  const nutriTotal = emptyNutri();
  for (const m of meals) {
    daysSet.add(m.meal_date);
    const prods = (m.meal_items || []).map(itemInfo);
    mealById[m.id] = prods;
    (productsByDate[m.meal_date] ??= []).push(...prods);
    for (const p of prods) {
      totalItems++;
      const f = foodFreq.get(p.name) || { emoji: p.emoji, count: 0 };
      f.count++; foodFreq.set(p.name, f);
      if (p.cat) catFreq.set(p.cat, (catFreq.get(p.cat) || 0) + 1);
    }
    for (const it of (m.meal_items || [])) addNutri(nutriTotal, itemNutrition(it));
  }

  // Corrélation aliment ↔ ressenti + ressenti par jour
  const foodFeel = new Map(), feelByDate = new Map();
  const allFeel = [];
  for (const h of health) {
    if (h.feeling == null) continue;
    daysSet.add(h.log_date);
    allFeel.push(h.feeling);
    if (!feelByDate.has(h.log_date)) feelByDate.set(h.log_date, []);
    feelByDate.get(h.log_date).push(h.feeling);
    const prods = h.meal_id ? (mealById[h.meal_id] || []) : (productsByDate[h.log_date] || []);
    const seen = new Set();
    for (const p of prods) {
      if (seen.has(p.name)) continue; seen.add(p.name);
      const e = foodFeel.get(p.name) || { emoji: p.emoji, feelings: [] };
      e.feelings.push(h.feeling); foodFeel.set(p.name, e);
    }
  }

  const MIN_OBS = 2;
  const scored = [...foodFeel.entries()]
    .filter(([, v]) => v.feelings.length >= MIN_OBS)
    .map(([name, v]) => ({ name, emoji: v.emoji, n: v.feelings.length, avg: average(v.feelings) }));
  const watch = scored.filter(s => s.avg <= 2.5).sort((a, b) => a.avg - b.avg).slice(0, 8);
  const good = scored.filter(s => s.avg >= 4).sort((a, b) => b.avg - a.avg).slice(0, 8);

  const topFoods = [...foodFreq.entries()].map(([name, v]) => ({ name, emoji: v.emoji, count: v.count }))
    .sort((a, b) => b.count - a.count).slice(0, 8);
  const maxFood = topFoods[0]?.count || 1;

  const catRows = [...catFreq.entries()].map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count);
  const maxCat = catRows[0]?.count || 1;

  // Boissons
  let totalGlasses = 0; const drinkByType = new Map();
  for (const d of drinks) {
    totalGlasses += Number(d.glasses || 0);
    drinkByType.set(d.drink_type, (drinkByType.get(d.drink_type) || 0) + Number(d.glasses || 0));
    daysSet.add(d.log_date);
  }
  const water = drinkByType.get("eau") || 0;
  const sugary = (drinkByType.get("sucree") || 0) + (drinkByType.get("gazeuse") || 0);
  const sugaryPct = totalGlasses ? Math.round(sugary / totalGlasses * 100) : 0;

  // Symptômes
  const symFreq = new Map();
  for (const h of health) for (const s of (h.symptoms || [])) symFreq.set(s, (symFreq.get(s) || 0) + 1);
  const topSym = [...symFreq.entries()].map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count).slice(0, 8);
  const maxSym = topSym[0]?.count || 1;

  // Activités
  let totMin = 0, totCal = 0; const actDays = new Set();
  for (const a of acts) { totMin += a.duration_min || 0; totCal += a.calories || 0; actDays.add(a.activity_date); daysSet.add(a.activity_date); }

  // Tendance ressenti (30 derniers jours avec données)
  const trend = [...feelByDate.keys()].sort().slice(-30).map(d => ({ d, avg: average(feelByDate.get(d)) }));

  const nDays = Math.max(1, daysSet.size);
  const kFeel = allFeel.length ? average(allFeel).toFixed(1) : null;
  const kFeelEmoji = kFeel ? (FEELINGS.find(f => f.v === Math.round(kFeel))?.e || "") : "—";

  // ---- Helpers de rendu ----
  const bar = (label, val, max, opts = {}) => `
    <div class="bar-item">
      <div class="bar-head"><span>${label}</span><span class="bar-val">${opts.right ?? val}</span></div>
      <div class="bar-track"><div class="bar-fill ${opts.cls || ""}" style="width:${Math.max(4, Math.round(val / max * 100))}%"></div></div>
    </div>`;
  const flag = (s, warn) => `
    <div class="food-flag">
      <span class="ff-emoji">${s.emoji}</span>
      <div class="ff-body"><div class="ff-name">${esc(s.name)}</div><div class="ff-sub">${s.n} observation${s.n > 1 ? "s" : ""}</div></div>
      <div class="ff-score ${warn ? "warn" : "good"}">${FEELINGS.find(f => f.v === Math.round(s.avg))?.e || ""} ${s.avg.toFixed(1)}/5</div>
    </div>`;

  // ---- Assemblage ----
  let html = "";

  if (!meals.length && !health.length && !drinks.length && !acts.length) {
    el("stats-body").innerHTML = `<div class="analysis-card"><p class="empty-hint">
      Aucune donnée sur cette période. Enregistrez vos repas et votre bien-être quelques jours,
      puis revenez ici : les analyses se construiront automatiquement.</p></div>`;
    return;
  }

  // KPIs
  html += `<div class="day-summary" style="margin-bottom:18px">
    <div class="stat-tile"><div class="v">${nDays}</div><div class="l">jours suivis</div></div>
    <div class="stat-tile"><div class="v">${meals.length}</div><div class="l">repas</div></div>
    <div class="stat-tile"><div class="v">${(totalItems / nDays).toFixed(1)}</div><div class="l">aliments/jour</div></div>
    <div class="stat-tile"><div class="v">${(totalGlasses / nDays).toFixed(1)}</div><div class="l">verres/jour</div></div>
    <div class="stat-tile"><div class="v">${kFeelEmoji}${kFeel ? " " + kFeel : ""}</div><div class="l">ressenti moyen</div></div>
    <div class="stat-tile"><div class="v">${acts.length}</div><div class="l">activités</div></div>
  </div>`;

  // Nutrition estimée (moyenne par jour)
  if (nutriTotal.kcal > 0) {
    const avg = k => nutriTotal[k] / nDays;
    html += `<div class="analysis-card">
      <h3>🍽️ Nutrition estimée <span style="font-size:12px;color:var(--ink-soft);font-weight:600">· moyenne/jour</span></h3>
      <div class="day-summary" style="margin:6px 0 0">
        <div class="stat-tile"><div class="v">${r0(avg("kcal"))}</div><div class="l">kcal</div></div>
        <div class="stat-tile"><div class="v">${r0(avg("carb"))}<span class="u">g</span></div><div class="l">glucides</div></div>
        <div class="stat-tile"><div class="v">${r0(avg("sugar"))}<span class="u">g</span></div><div class="l">dont sucres</div></div>
        <div class="stat-tile"><div class="v">${r0(avg("fat"))}<span class="u">g</span></div><div class="l">mat. grasses</div></div>
        <div class="stat-tile"><div class="v">${r0(avg("prot"))}<span class="u">g</span></div><div class="l">protéines</div></div>
        <div class="stat-tile"><div class="v">${r1(avg("salt"))}<span class="u">g</span></div><div class="l">sel</div></div>
      </div>
      <p class="sub" style="margin-top:10px">Estimation d'après les valeurs moyennes du catalogue et la taille de portion. Les aliments saisis librement (hors catalogue) ne sont pas comptés.</p>
    </div>`;
  }

  // Aliments à surveiller
  html += `<div class="analysis-card">
    <h3>⚠️ Aliments à surveiller</h3>
    <div class="sub">Aliments associés à un ressenti faible après ingestion (≥ ${MIN_OBS} observations).</div>`;
  if (!allFeel.length) {
    html += `<div class="unlock-hint">💡 Notez votre <b>bien-être après les repas</b> (onglet 💚 ou bouton flottant) pour débloquer l'analyse des aliments à éviter. Reliez chaque observation au repas concerné pour un résultat précis.</div>`;
  } else if (!watch.length) {
    html += `<p class="empty-hint">Aucun aliment ne ressort négativement pour l'instant 👍 Continuez à noter vos ressentis pour affiner.</p>`;
  } else {
    html += watch.map(s => flag(s, true)).join("");
  }
  html += `</div>`;

  // Aliments qui réussissent
  if (good.length) {
    html += `<div class="analysis-card">
      <h3>💚 Ce qui vous réussit</h3>
      <div class="sub">Aliments associés à un bon ressenti après ingestion.</div>
      ${good.map(s => flag(s, false)).join("")}</div>`;
  }

  // Tendance du ressenti
  if (trend.length) {
    html += `<div class="analysis-card">
      <h3>📈 Évolution du ressenti</h3>
      <div class="sub">Moyenne quotidienne (${trend.length} jour${trend.length > 1 ? "s" : ""} avec observation).</div>
      <div class="trend">${trend.map(t => `<div class="trend-bar" title="${t.d} : ${t.avg.toFixed(1)}/5" style="height:${Math.round(t.avg / 5 * 100)}%;background:${feelColor(t.avg)}"></div>`).join("")}</div>
      <div class="trend-scale"><span>😣 1</span><span>😀 5</span></div></div>`;
  }

  // Aliments les plus fréquents
  if (topFoods.length) {
    html += `<div class="analysis-card">
      <h3>🍽️ Aliments les plus consommés</h3>
      ${topFoods.map(f => bar(`${f.emoji} ${esc(f.name)}`, f.count, maxFood, { right: `${f.count}×` })).join("")}</div>`;
  }

  // Répartition par catégorie
  if (catRows.length) {
    const totalCat = catRows.reduce((s, c) => s + c.count, 0) || 1;
    html += `<div class="analysis-card">
      <h3>🗂️ Répartition par catégorie</h3>
      ${catRows.map(c => bar(esc(c.name), c.count, maxCat, { right: `${Math.round(c.count / totalCat * 100)}%` })).join("")}</div>`;
  }

  // Boissons
  if (drinks.length) {
    html += `<div class="analysis-card">
      <h3>🥤 Hydratation & boissons</h3>
      <div class="sub">Sur la période : ${totalGlasses} verres au total.</div>
      ${bar("💧 Eau", water, totalGlasses || 1, { cls: "sky", right: `${water}` })}
      ${bar("🥤 Sucrées / gazeuses", sugary, totalGlasses || 1, { cls: "warn", right: `${sugary} (${sugaryPct}%)` })}
      ${sugaryPct >= 25 ? `<div class="unlock-hint" style="margin-top:10px">🎯 ${sugaryPct}% de vos boissons sont sucrées/gazeuses — un levier direct pour la perte de poids.</div>` : ""}
    </div>`;
  }

  // Symptômes
  if (topSym.length) {
    html += `<div class="analysis-card">
      <h3>🩺 Symptômes les plus fréquents</h3>
      ${topSym.map(s => bar(esc(s.name), s.count, maxSym, { cls: "warn", right: `${s.count}×` })).join("")}</div>`;
  }

  // Activité
  if (acts.length) {
    html += `<div class="analysis-card">
      <h3>🏃 Activité physique</h3>
      <div class="day-summary" style="margin:6px 0 0">
        <div class="stat-tile"><div class="v">${actDays.size}</div><div class="l">jours actifs</div></div>
        <div class="stat-tile"><div class="v">${totMin}</div><div class="l">minutes</div></div>
        <div class="stat-tile"><div class="v">${totCal || "–"}</div><div class="l">kcal dépensées</div></div>
      </div></div>`;
  }

  html += `<p class="stats-note">Les corrélations sont indicatives et fondées sur vos propres observations : plus vous notez vos repas et votre bien-être, plus elles deviennent fiables. Elles ne remplacent pas un avis médical.</p>`;

  el("stats-body").innerHTML = html;
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
        <button class="btn btn-soft btn-sm" id="manage-products">Gérer</button></div>
      <p class="muted" style="margin-top:8px">Voir tous les produits et leurs valeurs nutritionnelles, les modifier, en ajouter, et importer / exporter (CSV).</p>
    </div>

    <div class="settings-card">
      <h3>📝 Notes & idées</h3>
      <div class="settings-row"><span class="muted">Notes libres et idées d'amélioration (texte ou audio)</span>
        <button class="btn btn-soft btn-sm" id="open-notes">Ouvrir</button></div>
    </div>

    <div class="settings-card">
      <h3>💾 Sauvegarde de mes données</h3>
      <p class="muted" style="margin-bottom:10px">Téléchargez une copie de vos données (à ranger dans votre Drive / cloud au cas où).</p>
      <div class="pm-actions">
        <button class="btn btn-soft btn-sm" id="export-json">⬇️ Sauvegarde complète (JSON)</button>
        <button class="btn btn-ghost btn-sm" id="export-journal">📄 Journal (CSV)</button>
      </div>
    </div>

    <div class="settings-card">
      <h3>📊 Analyses</h3>
      <p class="muted">Retrouvez dans l'onglet <b>📊 Analyses</b> les aliments à surveiller,
      ceux qui vous réussissent, l'évolution de votre ressenti et vos statistiques.</p>
    </div>

    <div class="settings-card">
      <h3>📝 Nouveautés & versions</h3>
      <div class="settings-row"><span class="muted">Historique des évolutions de l'app</span>
        <button class="btn btn-soft btn-sm" id="show-changelog">Voir le journal</button></div>
    </div>

    <div class="settings-card">
      <h3>📱 Installer l'application</h3>
      <p class="muted">Sur iPhone : bouton Partager → « Sur l'écran d'accueil ».<br>
      Sur ordinateur : icône d'installation dans la barre d'adresse.</p>
    </div>

    <div class="version-badge" id="version-badge" style="cursor:pointer" title="Voir les nouveautés">Version ${window.APP_CONFIG?.APP_VERSION || "1.0.0"} · Mon Journal Alimentaire</div>
    <p class="signature">By <span>Tadam-3D</span></p>
  `;
  el("logout-btn").onclick = logout;
  el("manage-products").onclick = openProductManager;
  el("open-notes").onclick = openNotesManager;
  el("export-json").onclick = exportAllData;
  el("export-journal").onclick = exportJournalCSV;
  el("show-changelog").onclick = openChangelogModal;
  el("version-badge").onclick = openChangelogModal;
}

/* ============================================================
   MODALE : NOTES (texte + audio, modifiables / supprimables)
   ============================================================ */
function mimeToExt(mime = "") {
  if (mime.includes("webm")) return "webm";
  if (mime.includes("mp4") || mime.includes("m4a") || mime.includes("aac")) return "m4a";
  if (mime.includes("ogg")) return "ogg";
  if (mime.includes("mpeg") || mime.includes("mp3")) return "mp3";
  if (mime.includes("wav")) return "wav";
  return "bin";
}

async function openNotesManager() {
  const overlay = openModal(`
    <div class="modal-head"><h2>📝 Notes & idées</h2><button class="modal-close">✕</button></div>
    <p class="pick-hint">Vos idées d'amélioration de l'application (texte et/ou audio).</p>
    <div class="note-composer">
      <textarea id="note-text" placeholder="Écrire une note…"></textarea>
      <div class="note-rec-row">
        <button class="btn btn-soft btn-sm" id="note-rec">🎤 Enregistrer un audio</button>
        <span id="note-rec-status" class="note-rec-status"></span>
      </div>
      <div id="note-audio-preview"></div>
      <button class="btn btn-primary btn-block" id="note-add">Ajouter la note</button>
    </div>
    <div id="notes-list" class="notes-list"><p class="empty-hint">Chargement…</p></div>
  `);
  const textEl = overlay.querySelector("#note-text");
  const recBtn = overlay.querySelector("#note-rec");
  const recStatus = overlay.querySelector("#note-rec-status");
  const audioPreview = overlay.querySelector("#note-audio-preview");
  const listEl = overlay.querySelector("#notes-list");
  const addBtn = overlay.querySelector("#note-add");

  let mediaRecorder = null, chunks = [], recordedBlob = null, recTimer = null, recSeconds = 0;
  const stopStream = () => { if (mediaRecorder?.stream) mediaRecorder.stream.getTracks().forEach(t => t.stop()); };
  const resetComposerAudio = () => { recordedBlob = null; audioPreview.innerHTML = ""; recStatus.textContent = ""; };

  async function toggleRec() {
    if (mediaRecorder && mediaRecorder.state === "recording") { mediaRecorder.stop(); return; }
    if (!navigator.mediaDevices?.getUserMedia || typeof MediaRecorder === "undefined")
      return toast("Enregistrement audio non disponible sur cet appareil", "err");
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      chunks = [];
      mediaRecorder = new MediaRecorder(stream);
      mediaRecorder.ondataavailable = e => { if (e.data.size) chunks.push(e.data); };
      mediaRecorder.onstop = () => {
        stopStream(); clearInterval(recTimer);
        recBtn.textContent = "🎤 Enregistrer un audio"; recBtn.classList.remove("recording");
        recordedBlob = new Blob(chunks, { type: mediaRecorder.mimeType || "audio/webm" });
        const url = URL.createObjectURL(recordedBlob);
        audioPreview.innerHTML = `<div class="note-audio-preview"><audio controls src="${url}"></audio><button class="btn btn-danger btn-sm" id="note-audio-del">Retirer l'audio</button></div>`;
        audioPreview.querySelector("#note-audio-del").onclick = resetComposerAudio;
      };
      mediaRecorder.start();
      recSeconds = 0; recBtn.textContent = "⏹ Arrêter"; recBtn.classList.add("recording");
      recStatus.textContent = "● 0:00";
      recTimer = setInterval(() => { recSeconds++; recStatus.textContent = `● ${Math.floor(recSeconds/60)}:${String(recSeconds%60).padStart(2,"0")}`; }, 1000);
    } catch (e) { toast("Autorisez le micro pour enregistrer", "err"); }
  }
  recBtn.onclick = toggleRec;

  async function load() {
    if (!document.body.contains(listEl)) return;
    const { data } = await supabase.from("notes").select("*").order("created_at", { ascending: false });
    await renderList(data || []);
  }

  async function renderList(notes) {
    if (!notes.length) { listEl.innerHTML = `<p class="empty-hint">Aucune note pour l'instant.</p>`; return; }
    const parts = [];
    for (const n of notes) {
      let audioHtml = "";
      if (n.audio_path) {
        const { data: signed } = await supabase.storage.from("notes-audio").createSignedUrl(n.audio_path, 3600);
        if (signed?.signedUrl) audioHtml = `<audio class="note-audio" controls src="${signed.signedUrl}"></audio>`;
      }
      const date = new Date(n.created_at).toLocaleString("fr-FR", { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
      const edited = n.updated_at && n.updated_at !== n.created_at ? " · modifiée" : "";
      parts.push(`<div class="note-item">
        <div class="note-head"><span class="note-date">🕐 ${date}${edited}</span>
          <span class="note-actions">
            <button class="pm-icon" data-edit="${n.id}" title="Modifier">✏️</button>
            <button class="pm-icon" data-del="${n.id}" title="Supprimer">🗑️</button>
          </span></div>
        ${n.content ? `<div class="note-content">${esc(n.content).replace(/\n/g, "<br>")}</div>` : ""}
        ${audioHtml}
      </div>`);
    }
    listEl.innerHTML = parts.join("");
    listEl.querySelectorAll("[data-edit]").forEach(b => b.onclick = () => editNote(notes.find(x => x.id === b.dataset.edit)));
    listEl.querySelectorAll("[data-del]").forEach(b => b.onclick = () => delNote(notes.find(x => x.id === b.dataset.del)));
  }

  async function editNote(note) {
    const next = prompt("Modifier la note :", note.content || "");
    if (next == null) return;
    const { error } = await supabase.from("notes").update({ content: next.trim() || null, updated_at: new Date().toISOString() }).eq("id", note.id);
    if (error) return toast("Erreur : " + error.message, "err");
    toast("Note modifiée", "ok"); load();
  }

  async function delNote(note) {
    if (!confirm("Supprimer cette note ?")) return;
    if (note.audio_path) await supabase.storage.from("notes-audio").remove([note.audio_path]);
    const { error } = await supabase.from("notes").delete().eq("id", note.id);
    if (error) return toast("Erreur : " + error.message, "err");
    toast("Note supprimée"); load();
  }

  addBtn.onclick = async () => {
    const content = textEl.value.trim();
    if (!content && !recordedBlob) return toast("Note vide", "err");
    addBtn.disabled = true;
    try {
      const { data: note, error } = await supabase.from("notes").insert({ content: content || null }).select().single();
      if (error) throw error;
      if (recordedBlob) {
        const path = `${state.user.id}/${note.id}.${mimeToExt(recordedBlob.type)}`;
        const { error: upErr } = await supabase.storage.from("notes-audio").upload(path, recordedBlob, { contentType: recordedBlob.type, upsert: true });
        if (upErr) throw upErr;
        await supabase.from("notes").update({ audio_path: path, audio_mime: recordedBlob.type }).eq("id", note.id);
      }
      textEl.value = ""; resetComposerAudio();
      toast("Note ajoutée", "ok"); load();
    } catch (e) { toast("Erreur : " + e.message, "err"); }
    finally { addBtn.disabled = false; }
  };

  overlay.querySelector(".modal-close").onclick = () => {
    if (mediaRecorder?.state === "recording") mediaRecorder.stop();
    stopStream(); closeModal(overlay);
  };
  load();
}

/* ============================================================
   SAUVEGARDE / EXPORT COMPLET DES DONNÉES
   ============================================================ */
function downloadBlob(blob, filename) {
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
}
function csvCell(v) { v = v == null ? "" : String(v); return /[",\n;]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v; }

// Export JSON complet (sauvegarde restaurable de toutes vos données)
async function exportAllData() {
  toast("Préparation de la sauvegarde…");
  const tables = ["meals", "meal_items", "drinks", "health_states", "activities", "products", "notes", "categories"];
  const dump = {
    app: "Mon Journal Alimentaire — By Tadam-3D",
    exported_at: new Date().toISOString(),
    app_version: window.APP_CONFIG?.APP_VERSION || null,
    user_email: state.user?.email || null,
    data: {},
  };
  for (const t of tables) {
    const { data, error } = await supabase.from(t).select("*");
    dump.data[t] = error ? { error: error.message } : data;
  }
  downloadBlob(new Blob([JSON.stringify(dump, null, 2)], { type: "application/json" }),
    `sauvegarde-journal-${todayISO()}.json`);
  toast("Sauvegarde exportée ✓", "ok");
}

// Export du journal (repas + aliments + nutrition) en CSV pour tableur
async function exportJournalCSV() {
  toast("Préparation du CSV…");
  const { data: meals } = await supabase.from("meals")
    .select("meal_date, meal_type, meal_time, meal_items(custom_name, quantity_kind, quantity_number, products(name,energy_kcal,carb_g,sugar_g,fat_g,protein_g,salt_g,portion_g))")
    .order("meal_date");
  const header = ["Date", "Heure", "Repas", "Aliment", "Quantité", "kcal", "Glucides_g", "Sucres_g", "MatGrasses_g", "Proteines_g", "Sel_g"];
  const lines = [header.join(",")];
  for (const m of (meals || [])) {
    const label = mealMeta(m.meal_type).label;
    for (const it of (m.meal_items || [])) {
      const name = it.products?.name || it.custom_name || "Aliment";
      const qty = it.quantity_kind === "nombre" ? `x${it.quantity_number ?? 1}` : cap(it.quantity_kind);
      const n = itemNutrition(it);
      lines.push([
        m.meal_date, (m.meal_time || "").slice(0, 5), label, name, qty,
        n ? r0(n.kcal) : "", n ? r1(n.carb) : "", n ? r1(n.sugar) : "",
        n ? r1(n.fat) : "", n ? r1(n.prot) : "", n ? r1(n.salt) : "",
      ].map(csvCell).join(","));
    }
  }
  downloadBlob(new Blob(["﻿" + lines.join("\n")], { type: "text/csv;charset=utf-8" }),
    `journal-alimentaire-${todayISO()}.csv`);
  toast("Journal CSV exporté ✓", "ok");
}

/* ============================================================
   MODALE : JOURNAL DES VERSIONS (lu depuis CHANGELOG.md)
   ============================================================ */
async function openChangelogModal() {
  const overlay = openModal(`
    <div class="modal-head"><h2>📝 Nouveautés</h2><button class="modal-close">✕</button></div>
    <div id="changelog-body" class="changelog"><p class="empty-hint">Chargement…</p></div>
  `);
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);
  try {
    const res = await fetch("CHANGELOG.md?t=" + Date.now());
    if (!res.ok) throw new Error("indisponible");
    overlay.querySelector("#changelog-body").innerHTML = renderMarkdownChangelog(await res.text());
  } catch (e) {
    overlay.querySelector("#changelog-body").innerHTML =
      `<p class="empty-hint">Journal des versions indisponible pour le moment.</p>`;
  }
}

// Rendu minimal du sous-ensemble Markdown utilisé dans CHANGELOG.md
function renderMarkdownChangelog(md) {
  const inline = (s) => esc(s)
    .replace(/\*\*(.+?)\*\*/g, "<b>$1</b>")
    .replace(/\[(.+?)\]\((.+?)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
  let html = "", inList = false;
  const closeList = () => { if (inList) { html += "</ul>"; inList = false; } };
  for (const raw of md.split("\n")) {
    const line = raw.trim();
    if (!line) { closeList(); continue; }
    if (line.startsWith("# ")) { closeList(); continue; }           // titre principal ignoré
    if (line.startsWith("## ")) { closeList(); html += `<h3 class="cl-version">${inline(line.slice(3))}</h3>`; continue; }
    if (line.startsWith("### ")) { closeList(); html += `<h4 class="cl-sub">${inline(line.slice(4))}</h4>`; continue; }
    if (line.startsWith("- ")) { if (!inList) { html += `<ul class="cl-list">`; inList = true; } html += `<li>${inline(line.slice(2))}</li>`; continue; }
    closeList(); html += `<p class="cl-p">${inline(line)}</p>`;
  }
  closeList();
  return html;
}

// Rétro-compat : ancien point d'entrée
function openAddProductModal() { openProductForm(null); }

/* ---------- Formulaire produit (ajout OU modification) ---------- */
function openProductForm(existing = null) {
  const isEdit = !!existing;
  const val = (k) => { const v = existing?.[k]; return v == null ? "" : v; };
  const overlay = openModal(`
    <div class="modal-head"><h2>${isEdit ? "✏️ Modifier le produit" : "➕ Nouveau produit"}</h2><button class="modal-close">✕</button></div>
    <div class="field"><label>Catégorie</label>
      <select id="p-cat">${state.categories.map(c => `<option value="${c.id}" ${c.id === existing?.category_id ? "selected" : ""}>${c.emoji} ${esc(c.name)}</option>`).join("")}</select></div>
    <div class="field"><label>Nom du produit</label><input type="text" id="p-name" value="${esc(val("name"))}" placeholder="Ex : Houmous"></div>
    <div class="field"><label>Emoji (optionnel)</label><input type="text" id="p-emoji" value="${esc(val("emoji"))}" placeholder="🥙" maxlength="4"></div>
    <div class="nutri-form">
      <div class="nutri-form-title">Valeurs nutritionnelles <span>(pour 100 g)</span></div>
      <div class="nutri-grid">
        <label>Énergie (kcal)<input type="number" id="n-kcal" min="0" step="1" value="${val("energy_kcal")}"></label>
        <label>Glucides (g)<input type="number" id="n-carb" min="0" step="0.1" value="${val("carb_g")}"></label>
        <label>dont sucres (g)<input type="number" id="n-sugar" min="0" step="0.1" value="${val("sugar_g")}"></label>
        <label>Mat. grasses (g)<input type="number" id="n-fat" min="0" step="0.1" value="${val("fat_g")}"></label>
        <label>Protéines (g)<input type="number" id="n-prot" min="0" step="0.1" value="${val("protein_g")}"></label>
        <label>Sel (g)<input type="number" id="n-salt" min="0" step="0.01" value="${val("salt_g")}"></label>
        <label>Portion (g)<input type="number" id="n-portion" min="0" step="1" value="${val("portion_g")}" placeholder="ex : 100"></label>
      </div>
    </div>
    <button class="btn btn-primary btn-block" id="save-product">${isEdit ? "Enregistrer" : "Ajouter à mon catalogue"}</button>
  `);
  overlay.querySelector(".modal-close").onclick = () => closeModal(overlay);
  overlay.querySelector("#save-product").onclick = async () => {
    const name = overlay.querySelector("#p-name").value.trim();
    if (!name) return toast("Indiquez un nom", "err");
    const num = id => { const v = overlay.querySelector(id).value; return v === "" ? null : Number(v); };
    const payload = {
      category_id: overlay.querySelector("#p-cat").value, name,
      emoji: overlay.querySelector("#p-emoji").value.trim() || null,
      energy_kcal: num("#n-kcal"), carb_g: num("#n-carb"), sugar_g: num("#n-sugar"),
      fat_g: num("#n-fat"), protein_g: num("#n-prot"), salt_g: num("#n-salt"), portion_g: num("#n-portion"),
    };
    try {
      if (isEdit) {
        const { data, error } = await supabase.from("products").update(payload).eq("id", existing.id).select();
        if (error) throw error;
        if (!data || !data.length) return toast("Modification non enregistrée : exécutez products-editable.sql", "err");
      } else {
        const { error } = await supabase.from("products").insert({ ...payload, user_id: state.user.id });
        if (error) throw error;
      }
      closeModal(overlay);
      toast(isEdit ? "Produit modifié" : "Produit ajouté", "ok");
      await loadCatalog();
      if (productManagerRefresh) productManagerRefresh();
      if (state.tab === "reglages") renderReglages();
    } catch (e) { toast("Erreur : " + e.message, "err"); }
  };
}

/* ---------- Gestionnaire de produits (liste + recherche + import/export) ---------- */
let productManagerRefresh = null;
async function openProductManager() {
  const overlay = openModal(`
    <div class="modal-head"><h2>🥗 Mes produits</h2><button class="modal-close">✕</button></div>
    <div class="pm-actions">
      <button class="btn btn-soft btn-sm" id="pm-add">➕ Nouveau</button>
      <button class="btn btn-ghost btn-sm" id="pm-export">⬇️ Exporter</button>
      <button class="btn btn-ghost btn-sm" id="pm-import">⬆️ Importer</button>
      <input type="file" id="pm-file" accept=".csv,text/csv" hidden>
    </div>
    <input type="text" id="pm-search" class="pm-search" placeholder="🔍 Rechercher un produit…">
    <div id="pm-list" class="pm-list"><p class="empty-hint">Chargement…</p></div>
  `);
  const search = overlay.querySelector("#pm-search");
  const listEl = overlay.querySelector("#pm-list");
  let all = [];

  async function load() {
    if (!document.body.contains(listEl)) return;
    const { data } = await supabase.from("products").select("*, categories(name,emoji)").order("name");
    all = data || [];
    render();
  }
  productManagerRefresh = load;

  function render() {
    const q = search.value.trim().toLowerCase();
    const rows = all.filter(p => !q || p.name.toLowerCase().includes(q));
    if (!rows.length) { listEl.innerHTML = `<p class="empty-hint">Aucun produit trouvé.</p>`; return; }
    const byCat = {};
    for (const p of rows) { const cn = p.categories?.name || "Autres"; (byCat[cn] ??= []).push(p); }
    listEl.innerHTML = Object.keys(byCat).sort().map(cn =>
      `<div class="pm-cat">${esc(cn)} <span>${byCat[cn].length}</span></div>` +
      byCat[cn].map(pmRow).join("")).join("");
    listEl.querySelectorAll("[data-edit]").forEach(b => b.onclick = () => openProductForm(all.find(x => x.id === b.dataset.edit)));
    listEl.querySelectorAll("[data-arch]").forEach(b => b.onclick = () => toggleArchive(b.dataset.arch));
  }

  function pmRow(p) {
    const off = p.is_active === false;
    const sub = p.energy_kcal != null
      ? `${r0(p.energy_kcal)} kcal · 🍬 ${r1(p.sugar_g || 0)}g · 🧈 ${r1(p.fat_g || 0)}g · 🥩 ${r1(p.protein_g || 0)}g /100g${p.portion_g ? ` · portion ${r0(p.portion_g)}g` : ""}`
      : `pas de valeurs nutritionnelles`;
    return `<div class="pm-row ${off ? "pm-off" : ""}">
      <span class="pm-emoji">${p.emoji || "🍴"}</span>
      <div class="pm-body">
        <div class="pm-name">${esc(p.name)}${p.user_id ? ' <span class="pm-tag">perso</span>' : ""}${off ? ' <span class="pm-tag off">masqué</span>' : ""}</div>
        <div class="pm-sub">${sub}</div>
      </div>
      <button class="pm-icon" data-edit="${p.id}" title="Modifier">✏️</button>
      <button class="pm-icon" data-arch="${p.id}" title="${off ? "Réafficher" : "Masquer"}">${off ? "↩️" : "🗑️"}</button>
    </div>`;
  }

  async function toggleArchive(id) {
    const p = all.find(x => x.id === id);
    const target = (p.is_active === false); // masqué -> réactiver ; sinon masquer
    const { data, error } = await supabase.from("products").update({ is_active: target }).eq("id", id).select();
    if (error) return toast("Erreur : " + error.message, "err");
    if (!data || !data.length) return toast("Action refusée : exécutez products-editable.sql", "err");
    toast(target ? "Produit réaffiché" : "Produit masqué");
    await loadCatalog(); load();
  }

  overlay.querySelector("#pm-add").onclick = () => openProductForm(null);
  overlay.querySelector("#pm-export").onclick = () => exportProductsCSV(all);
  const fileInput = overlay.querySelector("#pm-file");
  overlay.querySelector("#pm-import").onclick = () => fileInput.click();
  fileInput.onchange = async () => { if (fileInput.files[0]) { await importProductsCSV(fileInput.files[0], all); fileInput.value = ""; } };
  search.oninput = render;
  overlay.querySelector(".modal-close").onclick = () => { productManagerRefresh = null; closeModal(overlay); };

  load();
}

/* ---------- Export CSV ---------- */
function exportProductsCSV(all) {
  const cell = v => { v = v == null ? "" : String(v); return /[",\n;]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v; };
  const header = ["categorie", "nom", "emoji", "energie_kcal_100g", "glucides_100g", "sucres_100g", "matieres_grasses_100g", "proteines_100g", "sel_100g", "portion_g"];
  const lines = [header.join(",")];
  for (const p of all) lines.push([
    p.categories?.name || "", p.name, p.emoji || "",
    p.energy_kcal, p.carb_g, p.sugar_g, p.fat_g, p.protein_g, p.salt_g, p.portion_g
  ].map(cell).join(","));
  const blob = new Blob(["﻿" + lines.join("\n")], { type: "text/csv;charset=utf-8" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = `produits-journal-${todayISO()}.csv`;
  document.body.appendChild(a); a.click(); a.remove();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
  toast(`${all.length} produits exportés`, "ok");
}

/* ---------- Import CSV ---------- */
function parseCSV(text) {
  const rows = []; let field = "", row = [], inQ = false, i = 0;
  text = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  if (text.charCodeAt(0) === 0xFEFF) text = text.slice(1);
  const pushF = () => { row.push(field); field = ""; };
  const pushR = () => { rows.push(row); row = []; };
  while (i < text.length) {
    const c = text[i];
    if (inQ) {
      if (c === '"') { if (text[i + 1] === '"') { field += '"'; i += 2; continue; } inQ = false; i++; continue; }
      field += c; i++; continue;
    }
    if (c === '"') { inQ = true; i++; continue; }
    if (c === "," || c === ";") { pushF(); i++; continue; }
    if (c === "\n") { pushF(); pushR(); i++; continue; }
    field += c; i++;
  }
  if (field.length || row.length) { pushF(); pushR(); }
  return rows.filter(r => r.some(c => c.trim() !== ""));
}

async function importProductsCSV(file, existingList) {
  try {
    const rows = parseCSV(await file.text());
    if (rows.length < 2) return toast("Fichier vide ou invalide", "err");
    const head = rows[0].map(h => h.trim().toLowerCase());
    const col = (...names) => head.findIndex(h => names.includes(h));
    const iName = col("nom", "name", "produit");
    if (iName < 0) return toast("Colonne « nom » introuvable dans le CSV", "err");
    const iCat = col("categorie", "catégorie", "category");
    const iEmoji = col("emoji");
    const iKcal = col("energie_kcal_100g", "energie", "kcal", "energy_kcal");
    const iCarb = col("glucides_100g", "glucides", "carb_g");
    const iSugar = col("sucres_100g", "sucres", "sugar_g");
    const iFat = col("matieres_grasses_100g", "matieres_grasses", "fat_g");
    const iProt = col("proteines_100g", "proteines", "protein_g");
    const iSalt = col("sel_100g", "sel", "salt_g");
    const iPortion = col("portion_g", "portion");
    const numAt = (r, idx) => { if (idx < 0) return null; const v = (r[idx] || "").trim().replace(",", "."); return v === "" ? null : (isNaN(Number(v)) ? null : Number(v)); };
    const catByName = new Map(state.categories.map(c => [c.name.toLowerCase(), c.id]));
    const keyOf = (name, catId) => `${(name || "").toLowerCase()}|${catId || ""}`;
    const existingByKey = new Map(existingList.map(p => [keyOf(p.name, p.category_id), p]));

    const toInsert = [], toUpdate = [];
    for (let r = 1; r < rows.length; r++) {
      const row = rows[r];
      const name = (row[iName] || "").trim();
      if (!name) continue;
      const catId = iCat >= 0 ? (catByName.get((row[iCat] || "").trim().toLowerCase()) || null) : null;
      const payload = {
        name, category_id: catId, emoji: iEmoji >= 0 ? ((row[iEmoji] || "").trim() || null) : null,
        energy_kcal: numAt(row, iKcal), carb_g: numAt(row, iCarb), sugar_g: numAt(row, iSugar),
        fat_g: numAt(row, iFat), protein_g: numAt(row, iProt), salt_g: numAt(row, iSalt), portion_g: numAt(row, iPortion),
      };
      const match = existingByKey.get(keyOf(name, catId));
      if (match) toUpdate.push({ id: match.id, payload });
      else toInsert.push({ ...payload, user_id: state.user.id });
    }
    if (!toInsert.length && !toUpdate.length) return toast("Aucune ligne exploitable", "err");
    if (!confirm(`Importer ce fichier ?\n• ${toInsert.length} produit(s) ajouté(s)\n• ${toUpdate.length} produit(s) mis à jour`)) return;

    let ok = 0, fail = 0;
    if (toInsert.length) {
      const { error } = await supabase.from("products").insert(toInsert);
      if (error) fail += toInsert.length; else ok += toInsert.length;
    }
    for (const u of toUpdate) {
      const { data, error } = await supabase.from("products").update(u.payload).eq("id", u.id).select("id");
      if (error || !data || !data.length) fail++; else ok++;
    }
    await loadCatalog();
    if (productManagerRefresh) productManagerRefresh();
    toast(`Import terminé : ${ok} OK${fail ? `, ${fail} échec(s)` : ""}`, fail ? "err" : "ok");
  } catch (e) { toast("Import impossible : " + e.message, "err"); }
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
  if (tab === "analyses") renderAnalyses();
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
  state.date = toISODate(d);
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
