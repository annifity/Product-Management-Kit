(function () {
  const catalog = window.ANNIFITY_CATALOG || {
    generatedAt: "",
    summary: { skillCount: 0, referenceCount: 0, workflowCount: 0, templateCount: 0 },
    skills: [],
    references: []
  };

  const capabilityGroups = [
    {
      id: "discovery",
      title: "Discovery and Strategy",
      summary: "Frame opportunities, validate problems, compare solution directions, and define success signals.",
      skills: ["po-brainstorming", "po-spec", "prd"],
      refs: ["product-discovery", "solution-exploration", "business-model-canvas", "metric-tree"],
      tone: "teal"
    },
    {
      id: "specification",
      title: "Specification",
      summary: "Turn BRDs, raw notes, workflows, data rules, and APIs into testable product specifications.",
      skills: ["po-spec", "prd", "knowledge"],
      refs: ["feature-design", "requirement-analysis", "default-brd", "workflow-spec", "api-contract"],
      tone: "blue"
    },
    {
      id: "planning",
      title: "Planning and Roadmap",
      summary: "Prioritize work, slice releases, build epics, prepare grooming, and expose dependency risk.",
      skills: ["po-plan", "user-story"],
      refs: ["prioritization", "product-roadmap", "story-map", "grooming-questions"],
      tone: "amber"
    },
    {
      id: "delivery",
      title: "Delivery Readiness",
      summary: "Check definition of ready, sprint readiness, risk, traceability, operations, and UAT coverage.",
      skills: ["po-review", "uat", "po-execution"],
      refs: ["sprint-readiness", "definition-of-ready", "risk-register", "rtm", "operational-readiness"],
      tone: "teal"
    },
    {
      id: "change",
      title: "Execution and Change",
      summary: "Answer implementation questions, govern requirement changes, update context, and preserve audit trail.",
      skills: ["po-execution", "change", "docs", "memories"],
      refs: ["change-governance", "spec-change-context", "decision-ledger", "jira", "confluence"],
      tone: "blue"
    },
    {
      id: "shipping",
      title: "Ship and Learn",
      summary: "Prepare release packages, rollout plans, support handoff, rollback, decision outcomes, and post-ship memory.",
      skills: ["po-ship", "docs", "memories", "knowledge"],
      refs: ["release-readiness", "rollout-plan", "release-note", "decision-outcomes"],
      tone: "amber"
    }
  ];

  const flow = [
    ["01", "po-brainstorming", "Fuzzy ideas, stakeholder asks, discovery, strategy, solution options."],
    ["02", "po-spec", "BRD, PRD input, workflow, data/API rules, requirements, edge cases."],
    ["03", "po-plan", "Roadmap, prioritization, release slices, epics, dependencies, grooming."],
    ["04", "po-execution", "Developer questions, blockers, scope decisions, implementation context."],
    ["05", "po-review", "Artifact quality, readiness, risk, traceability, UAT and delivery gates."],
    ["06", "po-ship", "Release, rollout, support handoff, release notes, post-ship learning."]
  ];

  const artifactSkills = new Set(["prd", "user-story", "uat", "change", "docs", "memories", "knowledge"]);
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

  function skillByName(name) {
    return catalog.skills.find((skill) => skill.name === name);
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
      generated.textContent = `Catalog: ${catalog.generatedAt}`;
    }
  }

  function renderCapabilities() {
    const grid = byId("capabilityGrid");
    grid.innerHTML = capabilityGroups.map((group) => `
      <article class="card">
        <div class="card-kicker">
          <span>${escapeHtml(group.id)}</span>
          <span class="pill ${group.tone}">${group.skills.length} skills</span>
        </div>
        <h3>${escapeHtml(group.title)}</h3>
        <p>${escapeHtml(group.summary)}</p>
        <div class="skill-list">
          ${group.skills.map((skill) => `<span class="pill ${group.tone}">${escapeHtml(skill)}</span>`).join("")}
        </div>
      </article>
    `).join("");
  }

  function renderFlow() {
    const list = byId("flowList");
    list.innerHTML = flow.map(([number, skill, summary]) => `
      <div class="flow-step">
        <strong>${escapeHtml(number)} ${escapeHtml(skill)}</strong>
        <p>${escapeHtml(summary)}</p>
      </div>
    `).join("");
  }

  function renderFilters() {
    const filters = byId("filters");
    const items = [
      ["all", "All"],
      ["flow", "Flow skills"],
      ["artifact", "Artifact skills"],
      ...capabilityGroups.map((group) => [group.id, group.title])
    ];

    filters.innerHTML = items.map(([id, label]) => `
      <button type="button" data-filter="${escapeHtml(id)}" class="${id === activeFilter ? "active" : ""}">
        ${escapeHtml(label)}
      </button>
    `).join("");

    filters.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", () => {
        activeFilter = button.dataset.filter;
        renderFilters();
        renderSkills();
      });
    });
  }

  function skillMatchesFilter(skill) {
    if (activeFilter === "all") return true;
    if (activeFilter === "artifact") return artifactSkills.has(skill.name);
    if (activeFilter === "flow") return !artifactSkills.has(skill.name);
    const group = capabilityGroups.find((item) => item.id === activeFilter);
    return group ? group.skills.includes(skill.name) : true;
  }

  function skillMatchesSearch(skill, query) {
    if (!query) return true;
    const haystack = [
      skill.name,
      skill.description,
      skill.source,
      ...(skill.references || [])
    ].join(" ").toLowerCase();
    return haystack.includes(query);
  }

  function renderSkills() {
    const query = byId("searchInput").value.trim().toLowerCase();
    const skills = catalog.skills
      .filter((skill) => skillMatchesFilter(skill))
      .filter((skill) => skillMatchesSearch(skill, query));

    const grid = byId("skillGrid");
    if (!skills.length) {
      grid.innerHTML = `<div class="empty">No skills match the current filter.</div>`;
      return;
    }

    grid.innerHTML = skills.map((skill) => {
      const relatedGroups = capabilityGroups
        .filter((group) => group.skills.includes(skill.name))
        .map((group) => group.title);
      const refs = (skill.references || []).slice(0, 5);
      return `
        <article class="card skill-card">
          <div class="card-kicker">
            <span>${artifactSkills.has(skill.name) ? "artifact" : "flow"}</span>
            <span class="pill blue">${refs.length} refs</span>
          </div>
          <h3>${escapeHtml(skill.name)}</h3>
          <p>${escapeHtml(skill.description)}</p>
          <div class="skill-list">
            ${relatedGroups.map((group) => `<span class="pill teal">${escapeHtml(group)}</span>`).join("")}
          </div>
          <div class="ref-list">
            ${refs.map((ref) => `<code>${escapeHtml(ref.replace("_refs/", ""))}</code>`).join("")}
          </div>
          <code class="path">${escapeHtml(skill.source)}</code>
        </article>
      `;
    }).join("");
  }

  function renderReferences() {
    const target = byId("referenceGroups");
    const groups = catalog.references.reduce((acc, ref) => {
      acc[ref.group] = acc[ref.group] || [];
      acc[ref.group].push(ref);
      return acc;
    }, {});

    const preferredOrder = ["overview", "workflows", "checklists", "templates", "schemas", "integrations", "operating-model"];
    const names = Object.keys(groups).sort((a, b) => {
      const ai = preferredOrder.indexOf(a);
      const bi = preferredOrder.indexOf(b);
      if (ai === -1 && bi === -1) return a.localeCompare(b);
      if (ai === -1) return 1;
      if (bi === -1) return -1;
      return ai - bi;
    });

    target.innerHTML = names.map((name) => {
      const refs = groups[name];
      return `
        <article class="reference-card">
          <h3>${escapeHtml(name)} <span>${refs.length}</span></h3>
          <div class="ref-list">
            ${refs.slice(0, 12).map((ref) => `<code>${escapeHtml(ref.path.replace(`_refs/${name}/`, ""))}</code>`).join("")}
          </div>
        </article>
      `;
    }).join("");
  }

  function bindSearch() {
    const input = byId("searchInput");
    input.addEventListener("input", renderSkills);
  }

  renderSummary();
  renderCapabilities();
  renderFlow();
  renderFilters();
  renderSkills();
  renderReferences();
  bindSearch();
}());
