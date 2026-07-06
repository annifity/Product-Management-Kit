(function () {
  const catalog = window.ANNIFITY_CATALOG || {
    generatedAt: "",
    summary: { skillCount: 0, referenceCount: 0, workflowCount: 0, templateCount: 0 },
    skills: [],
    references: []
  };

  const packs = [
    ["Discovery Pack", "Shape the opportunity", "Problem, users, evidence, options, assumptions, metric draft.", ["discovery", "brief"], "teal"],
    ["PRO Pack", "Prototype before PRD", "11-section PRO, golden paths, AI considerations, risks, prompt-ready builder input.", ["prototype"], "blue"],
    ["Experiment Pack", "Design the evidence", "Hypothesis, sample, metrics, guardrails, tracking, decision thresholds.", ["experiment", "validate"], "amber"],
    ["Build Handoff Pack", "Make scope buildable", "Spec IDs, workflows, business rules, data/API, NFRs, risk, traceability.", ["spec", "plan"], "purple"],
    ["Jira/UAT Pack", "Split and accept", "Epics, stories, acceptance criteria, UAT register, coverage matrix.", ["user-story", "uat"], "green"],
    ["Release Pack", "Ship and learn", "Readiness, rollout, rollback, support handoff, release notes, memory updates.", ["ship", "learn"], "red"]
  ];

  const loop = [
    ["Idea", "Raw ask or fuzzy opportunity"],
    ["PRO", "One-pager with goal, users, golden paths, risks, metrics"],
    ["Builder", "Tool-agnostic frontend prototype input"],
    ["Prototype", "Runnable FE with mock data"],
    ["Feedback", "Client/user review and observations"],
    ["Learn/Validate", "Evidence, decision, and next-loop recommendation"],
    ["PRD", "Detailed requirement after learning"]
  ];

  const capabilityGroups = [
    ["Discovery", "Find the right problem", ["discovery", "brief", "knowledge"], "teal"],
    ["Prototype", "Make ideas inspectable", ["prototype", "experiment", "validate", "learn"], "blue"],
    ["Requirements", "Turn evidence into scope", ["prd", "spec", "plan"], "amber"],
    ["Delivery", "Split, test, ship", ["user-story", "uat", "execution", "ship"], "green"],
    ["System", "Preserve context", ["docs", "memories", "change"], "purple"]
  ];

  const flowSkillNames = new Set(["discovery", "brief", "prototype", "experiment", "validate", "learn", "spec", "plan", "execution", "ship"]);
  let activeFilter = "all";

  function byId(id) {
    return document.getElementById(id);
  }

  function escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }

  function setText(id, value) {
    const node = byId(id);
    if (node) node.textContent = value;
  }

  function renderSummary() {
    setText("skillCount", catalog.summary.skillCount);
    setText("referenceCount", catalog.summary.referenceCount);
    setText("workflowCount", catalog.summary.workflowCount);
    setText("templateCount", catalog.summary.templateCount);

    const generated = byId("generatedAt");
    if (generated && catalog.generatedAt) {
      generated.textContent = `Catalog ${catalog.generatedAt}`;
    }
  }

  function renderPacks() {
    byId("packGrid").innerHTML = packs.map(([title, label, summary, skills, tone], index) => `
      <article class="info-card pack-card tone-${tone}">
        <div class="card-topline">
          <span class="step-number">${String(index + 1).padStart(2, "0")}</span>
          <span>${escapeHtml(label)}</span>
        </div>
        <h3>${escapeHtml(title)}</h3>
        <p>${escapeHtml(summary)}</p>
        <div class="tag-row">
          ${skills.map((skill) => `<span>${escapeHtml(skill)}</span>`).join("")}
        </div>
      </article>
    `).join("");
  }

  function renderLoop() {
    byId("loopGrid").innerHTML = loop.map(([title, summary], index) => `
      <article class="loop-card">
        <span>${String(index + 1).padStart(2, "0")}</span>
        <h3>${escapeHtml(title)}</h3>
        <p>${escapeHtml(summary)}</p>
      </article>
    `).join("");
  }

  function renderCapabilities() {
    byId("capabilityGrid").innerHTML = capabilityGroups.map(([title, summary, skills, tone]) => `
      <article class="capability-card tone-${tone}">
        <h3>${escapeHtml(title)}</h3>
        <p>${escapeHtml(summary)}</p>
        <div class="mini-list">
          ${skills.map((skill) => `<span>${escapeHtml(skill)}</span>`).join("")}
        </div>
      </article>
    `).join("");
  }

  function renderFilters() {
    const filters = [
      ["all", "All"],
      ["flow", "Flow"],
      ["artifact", "Artifacts"],
      ["system", "System"]
    ];

    byId("filters").innerHTML = filters.map(([id, label]) => `
      <button type="button" data-filter="${escapeHtml(id)}" class="${id === activeFilter ? "active" : ""}">
        ${escapeHtml(label)}
      </button>
    `).join("");

    byId("filters").querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", () => {
        activeFilter = button.dataset.filter;
        renderFilters();
        renderSkills();
      });
    });
  }

  function skillType(skill) {
    if (["docs", "memories", "knowledge"].includes(skill.name)) return "system";
    return flowSkillNames.has(skill.name) ? "flow" : "artifact";
  }

  function skillMatchesFilter(skill) {
    return activeFilter === "all" || skillType(skill) === activeFilter;
  }

  function skillMatchesSearch(skill, query) {
    if (!query) return true;
    return [skill.name, skill.description, skill.source, ...(skill.references || [])]
      .join(" ")
      .toLowerCase()
      .includes(query);
  }

  function renderSkills() {
    const query = byId("searchInput").value.trim().toLowerCase();
    const skills = catalog.skills
      .filter(skillMatchesFilter)
      .filter((skill) => skillMatchesSearch(skill, query));

    byId("skillResultCount").textContent = `${skills.length} of ${catalog.skills.length} skills`;

    if (!skills.length) {
      byId("skillGrid").innerHTML = `<div class="empty">No skills match this filter.</div>`;
      return;
    }

    byId("skillGrid").innerHTML = skills.map((skill) => {
      const refs = skill.references || [];
      return `
        <article class="skill-card">
          <div class="card-topline">
            <span>${escapeHtml(skillType(skill))}</span>
            <span>${refs.length} refs</span>
          </div>
          <h3>${escapeHtml(skill.name)}</h3>
          <p>${escapeHtml(skill.description)}</p>
          <code>${escapeHtml(skill.source)}</code>
        </article>
      `;
    }).join("");
  }

  function renderReferences() {
    const groups = catalog.references.reduce((acc, ref) => {
      acc[ref.group] = acc[ref.group] || 0;
      acc[ref.group] += 1;
      return acc;
    }, {});

    byId("referenceSummary").innerHTML = Object.entries(groups)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([group, count]) => `
        <div class="reference-row">
          <span>${escapeHtml(group)}</span>
          <strong>${count}</strong>
        </div>
      `).join("");
  }

  function bindSearch() {
    byId("searchInput").addEventListener("input", renderSkills);
  }

  renderSummary();
  renderPacks();
  renderLoop();
  renderCapabilities();
  renderFilters();
  renderSkills();
  renderReferences();
  bindSearch();
}());
