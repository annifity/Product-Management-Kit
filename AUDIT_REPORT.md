# Annifity Skill Repo Audit Report

Phạm vi: `skills/*` (19 canonical skills), `_refs/**` (190 file dùng chung), tooling/test harness (`tools/`, `tests/`), và repo-level config. Đối chiếu với `skill-creator` (chuẩn chung của Anthropic) và với chuẩn nội bộ mà chính repo tự đặt ra (`_refs/operating-model/skill-authoring.md`, `_refs/checklists/skill-quality.md`). Đây là audit read-only — chưa sửa bất kỳ file nào ngoài việc tạo file report này (theo đúng yêu cầu ở mục Output).

---

## 1. Executive Summary

Annifity là một skill repo **trưởng thành hơn hẳn** mức trung bình: 19 skill canonical, một bộ `_refs/` dùng chung (190 file), và một test harness riêng (routing fixtures, contract fixtures, semantic-forward eval, mutation-safety, drawio validation...) mà tự nó đã vượt qua mọi gate tự động (`guard`, `skill:validate`, `ref:check`, `routing:test`, `contract:test`, `sync:check` đều PASS khi tôi chạy trực tiếp). Vì vậy phần lớn lỗi "vi phạm chuẩn cơ bản" (frontmatter sai, orphan reference, description trống) **không tồn tại** — giá trị của audit này nằm ở các lỗi mà automation không bắt được: độ chính xác ngữ nghĩa của trigger, độ lệch giữa lời hứa output và template thật, và độ phủ vòng đời sản phẩm.

**5 vấn đề lớn nhất:**
1. **Template drift (P0):** `skills/spec/SKILL.md` hứa 15 mục output nhưng template mặc định `_refs/templates/spec/product-spec.md` chỉ có 6 mục — `contract:test` không bắt được vì nó chỉ so khớp một tập con chuỗi ký tự.
2. **Template drift lan rộng, chưa tới mức P0 nhưng cùng pattern:** `plan` hứa "Milestones" + "Dependency matrix" nhưng không có template nào hỗ trợ; `ship` hứa "EOL/retirement plan" nhưng thư mục `_refs/templates/release/` chỉ có 2 file (`go-to-market-plan.md`, `rollout-plan.md`), không có template retirement/EOL nào.
3. **Routing test coverage lệch:** `docs`, `execution`, `memories` chỉ có case "positive" (0 negative/ambiguous/handoff) dù đây là 3 skill có ranh giới ngữ nghĩa mong manh nhất với `knowledge`/`change`/`validate`.
4. **9 file `_refs/workflows|checklists` thiếu Good Example + Anti-pattern + Failure-modes** mà chính chuẩn nội bộ (`skill-authoring.md` §6, §9) yêu cầu cho reference "substantial" — một pattern lặp lại nhất quán qua nhiều skill khác nhau (authoring pass không đều).
5. **Không có `LICENSE` ở root** dù `.claude-plugin/plugin.json` đã định hình repo để phân phối như một Claude Code plugin — mâu thuẫn với `"private": true` trong `package.json`.

**Tổng token có thể giảm:** thấp hơn kỳ vọng ban đầu — kiến trúc progressive disclosure ở đây đã làm đúng (SKILL.md mỏng, `_refs/` chỉ load khi cần). Chi phí "luôn nằm trong context" chỉ là **~2,328 token** cho 19 description (xem Mục 7) — không phải hàng trăm nghìn token như khi cộng dồn cả `tools/`/`docs/`/`.annifity/` (những thư mục này agent không bao giờ load khi dùng skill). Tiềm năng giảm token thực tế: **~5-8%** trên phần luôn-resident (rút description dài nhất), cộng thêm loại bỏ 1 khối nội dung lặp 3 lần (PRO boundary list) — chỉ tiết kiệm khi `prototype` được trigger, không phải chi phí thường trực. Đổi lại, 4 fix mô tả (description) được đề xuất ở Mục 4 sẽ **làm dài thêm** một chút (~15-25 từ/skill) để giảm rủi ro misroute — đây là trade-off token-vs-độ-chính-xác cần nêu rõ, không phải mâu thuẫn với mục tiêu tiết kiệm token.

---

## 2. Rubric Đánh Giá

| # | Tiêu chí | Nguồn chuẩn | Ngưỡng/kỳ vọng |
|---|---|---|---|
| 1 | Frontmatter | skill-creator | Chỉ có `name` + `description`; không field khác |
| 2 | Naming | skill-creator + Annifity §1 | lowercase-kebab-case, ≤64 ký tự, tên folder = tên skill |
| 3 | Description — trigger phrase | skill-creator + Annifity §3 | Viết như trigger metadata, không phải copy quảng cáo; nêu rõ WHAT + WHEN |
| 4 | Description — ngôi thứ 3 | skill-creator | Không dùng "I/you", viết khách quan |
| 5 | Description — when-to-use vs when-NOT-to-use | skill-creator + Annifity §3 | Phải nêu ranh giới với skill lân cận gây nhầm lẫn nhất |
| 6 | Progressive disclosure | skill-creator + Annifity §5 | SKILL.md body < 500 dòng, chỉ chứa routing + quy trình cốt lõi; chi tiết đẩy ra reference |
| 7 | Tách reference file | skill-creator + Annifity §6 | Không nhồi template/ví dụ dài vào SKILL.md; mỗi reference có link trực tiếp từ SKILL.md (không nested sâu) |
| 8 | Reference quality | Annifity §6, §9 | Reference "substantial" phải có: lý do tồn tại, các bước có nhánh, ít nhất 1 Good Example + 1 Anti-pattern, bảng Failure Modes (signal/consequence/correction/prevention) |
| 9 | Script cho việc deterministic | skill-creator | Việc đếm/parse/validate/format nên dùng script thay vì để model tự suy luận trong prose |
| 10 | Output contract / "sao là đúng" | skill-creator + Annifity §15 | Skill phải định nghĩa rõ Output + điều kiện chấp nhận; output phải khớp với template nó trỏ tới |
| 11 | Cross-reference resolution | Annifity §10 | Mọi path `_refs/...` trong SKILL.md phải tồn tại; mọi file `_refs/` phải có ít nhất 1 route vào từ 1 skill |
| 12 | Trigger & routing test | Annifity §11 | Mỗi skill nên có case: positive, negative, ambiguous, handoff, và song ngữ EN/VI |
| 13 | Eval / semantic test | skill-creator (forward-test) + Annifity §11 | Có cơ chế test hành vi thật (không chỉ lexical), tách candidate/evaluator/oracle |

Rubric này gồm 2 lớp: **Lớp A** (chuẩn chung, cột "skill-creator") và **Lớp B** (chuẩn riêng mà chính Annifity tự đặt ra và tự validate bằng `npm run *`). Một finding chỉ tính P0 khi vi phạm cả logic vận hành thực sự (skill không trigger đúng / output không khớp template nó tự hứa), không chỉ là thiếu "nice-to-have".

---

## 3. Inventory

### 3.1 Repo-level

| File/thư mục | Có? | Ghi chú |
|---|---|---|
| `README.md` | ✅ | Đầy đủ, có mental model, builder packs, source-of-truth |
| `CLAUDE.md` / `AGENTS.md` | ✅ | Trùng nội dung phần lớn (adapter cho 2 runtime) |
| `.claude-plugin/plugin.json` | ✅ | Định danh plugin `annifity` v2.0.0, có `skills: ["./skills"]" |
| `LICENSE` | ❌ | **Thiếu** — xem finding repo-level P1 |
| `CONTRIBUTING.md` | ❌ | Thiếu — mức độ ưu tiên thấp hơn (P2) vì `package.json` khai `"private": true` |
| `package.json` scripts | ✅ | 25 script test/validate/sync, tổ chức theo p0/p1/p2 test tier — rất hiếm gặp ở skill repo thông thường |
| Test harness (`tests/fixtures/**`) | ✅ | routing, contracts, artifact-baselines, mutation-safety, drawio-validation, phase-gate-approval, semantic-forward, session-rework, repo-doctor — 8+ loại fixture khác nhau |

### 3.2 19 Skill Canonical (`skills/*/SKILL.md`)

| name | path | mô tả rút gọn | dòng | ref files (trong skill) | script? | agents/openai.yaml | token ước lượng (body) |
|---|---|---|---|---|---|---|---|
| brief | skills/brief | Brief 1 trang từ discovery đã xác nhận | 51 | 0 | ❌ | ✅ | 914 |
| change | skills/change | Đánh giá & áp dụng thay đổi có kiểm soát | 46 | 0 | ❌ | ✅ | 1,009 |
| design | skills/design | Spec đã duyệt → UX/UI design package | 61 | 0 | ❌ | ✅ | 1,669 |
| discovery | skills/discovery | Đóng khung vấn đề mơ hồ → hướng đi | 72 | 0 | ❌ | ✅ | 1,630 |
| docs | skills/docs | Lưu/versioning/index artifact | 66 | 0 | ❌ | ✅ | 1,381 |
| execution | skills/execution | Hỗ trợ quyết định PO khi đang triển khai | 49 | 0 | ❌ | ✅ | 1,004 |
| experiment | skills/experiment | Thiết kế experiment / AI eval plan | 54 | 0 | ❌ | ✅ | 999 |
| knowledge | skills/knowledge | Truy xuất kiến thức đã có, có trích dẫn | 40 | 0 | ❌ | ✅ | 632 |
| learn | skills/learn | Tổng hợp evidence → insight/quyết định | 59 | 0 | ❌ | ✅ | 1,236 |
| memories | skills/memories | Đọc/ghi context bền vững | 55 | 0 | ❌ | ✅ | 1,003 |
| plan | skills/plan | Spec đã duyệt → delivery plan | 54 | 0 | ❌ | ✅ | 1,154 |
| prd | skills/prd | Tạo/sửa/xuất PRD/BRD | 47 | 0 | ❌ | ✅ | 1,100 |
| prototype | skills/prototype | Build-to-learn prototype package (PRO) | 75 | 0 | ❌ | ✅ | 1,300 |
| ship | skills/ship | Release/rollout/retirement/handoff | 59 | 0 | ❌ | ✅ | 1,233 |
| spec | skills/spec | Nguồn sự thật chi tiết cho delivery | 67 | 0 | ❌ | ✅ | 1,559 |
| strategy | skills/strategy | Chiến lược & lựa chọn portfolio | 54 | 0 | ❌ | ✅ | 1,177 |
| uat | skills/uat | UAT plan/scenario/test-case register | 47 | 0 | ❌ | ✅ | 1,127 |
| user-story | skills/user-story | Story/epic/Jira ticket-ready | 52 | 0 | ❌ | ✅ | 1,415 |
| validate | skills/validate | Audit artifact/design/AI eval → verdict | 58 | 0 | ❌ | ✅ | 1,796 |
| **Tổng** | | | **1,036 dòng** | | | | **~23,338 token** |

Ghi chú quan trọng: "ref files: 0" và "script: ❌" ở **mọi** skill không phải là lỗi ngẫu nhiên — đây là **kiến trúc có chủ đích**: Annifity dùng **một `_refs/` dùng chung ở root** (190 file: `checklists/`, `templates/`, `schemas/`, `workflows/`, `operating-model/`, `integrations/`) thay vì thư mục `references/` riêng trong từng skill như khuyến nghị mặc định của `skill-creator`. Đây là điểm khác biệt kiến trúc cần đánh giá riêng (Mục 4, finding chung), không tự động là lỗi.

### 3.3 `_refs/` (190 file, ~412,348 ký tự ≈ 103,087 token — chỉ load khi được route tới)

| Thư mục con | Số file | Vai trò |
|---|---|---|
| `checklists/` | 32 | Quality/readiness gate |
| `templates/` | 90 | Khuôn artifact (PRD, spec, design, UAT, experiment...) |
| `workflows/` | 21 | Quy trình nhiều bước |
| `schemas/` | 17 | Contract máy đọc được (frontmatter, decision-record, metrics-event...) |
| `operating-model/` | 9 | Nguyên tắc vòng đời, routing, phase-gates, skill-authoring |
| `integrations/` | 6 | Ghi chú Jira/Confluence/Claude/Codex/Cursor/Copilot |

### 3.4 Ước lượng token nếu load toàn bộ repo (và vì sao con số này gây hiểu lầm)

| Thư mục | ~Token | Agent có bao giờ load không? |
|---|---|---|
| `skills/` | 24,351 | Có — nhưng chỉ description (2,328 token) luôn resident; phần còn lại chỉ khi trigger |
| `_refs/` | 103,087 | Chỉ khi 1 skill route cụ thể tới 1 file cụ thể |
| `tools/` | 173,593 | **Không bao giờ** — đây là script PowerShell cho CI/maintainer, không phải nội dung skill |
| `.annifity/` | 172,396 | **Không bao giờ** — runtime output, gitignored, project-local |
| `tests/` | 46,453 | **Không bao giờ** — chỉ chạy bởi `npm test`, không load vào context agent |
| `docs/` | 48,033 | **Không bao giờ** — static site output |
| `.claude/`, `.codex/`, `.github/`, `.cursor/` | ~25,000 | Đây là **bản sao generate** của `skills/`, agent chỉ đọc 1 bản tùy runtime, không phải cộng dồn |

→ Tổng "brute-force" nếu cộng hết là **~600,000+ token**, nhưng đây không phải con số có ý nghĩa vận hành. Chi phí thực tế cho một phiên làm việc bình thường là: 2,328 token (description, luôn có) + 1 SKILL.md body (~1,000-1,800 token, khi trigger) + 1-3 file `_refs/` được route tới cụ thể (thường 300-1,500 token/file). **Đề bài yêu cầu ước lượng token cho cả repo — số đó nằm ở bảng trên, nhưng khuyến nghị không dùng nó làm chỉ số tối ưu hoá chính**, vì tối ưu sai chỗ (ví dụ nén `tools/`) không ảnh hưởng gì tới hiệu năng agent.

---

## 4. Findings Theo Severity

### P0 — Sai chuẩn / output không khớp lời hứa

**F-P0-1 — `spec` output contract lệch khỏi template thật của chính nó**
- **File:line:** `skills/spec/SKILL.md:25-42` (mục "Spec Sections", hứa 15 mục: Users and roles, Workflow and state behavior, Data and integration notes, API contract notes, Business rules, Permissions and compliance notes, Acceptance signals, v.v.) vs. `_refs/templates/spec/product-spec.md` (chỉ có 6 mục: Context, Objective, Scope, Requirements, Risks, Open Questions).
- **Vấn đề → Tác động:** `tests/fixtures/contracts/all-skills-output-contract.json` chỉ so khớp đúng 6 chuỗi đó, nên `contract:test` PASS dù thiếu 9 mục — đây chính là "Template drift" mà `_refs/schemas/skill-output-contract.md:91` tự cảnh báo ("Skill promises data absent from its template" → "Generated output silently omits it"), nhưng bị chính test của repo bỏ sót vì test chỉ chọn subset. Agent sẽ tự bịa cấu trúc thiếu (business rules, permissions, acceptance signals) hoặc bỏ sót chúng, tùy phiên.
- **Fix:** (a) mở rộng `product-spec.md` để có đủ heading (đánh dấu optional cho phần ít dùng), hoặc (b) thu hẹp danh sách "Spec Sections" trong SKILL.md khớp với template hiện tại và đẩy phần "spec đầy đủ" (khi cần) sang một file `_refs/templates/spec/product-spec-full.md` riêng, route có điều kiện.
- **Severity: P0**

> **Ghi chú biên tập:** 2 finding dưới đây (`plan`, `ship`) là **cùng một pattern** (output hứa nhưng template không hỗ trợ) nhưng agent audit xếp P1 vì path vẫn resolve (không phải orphan reference kỹ thuật). Tôi giữ nguyên xếp hạng của agent để tôn trọng định nghĩa "Blocked" của chính `skill-quality.md` (chỉ dành cho broken/orphan reference), nhưng đề nghị bạn coi 3 finding này là **một nhóm hành động chung, ưu tiên ngang nhau trong thực tế** dù nhãn severity khác nhau.

### P1 — Chất lượng, thiếu when-NOT-to-use, coverage gap, template drift nhẹ hơn

**F-P1-1 — `plan` hứa output không có template hỗ trợ**
- **File:line:** `skills/plan/SKILL.md:30-31` (Output: "Milestones", "Dependency matrix").
- **Vấn đề → Tác động:** Không có template nào trong repo tạo ra lịch milestone hay ma trận dependency thật. `_refs/templates/plan/product-roadmap.md` chỉ có bảng Now/Next/Later với 1 ô "Dependencies" dạng free-text; `_refs/templates/user-story/story-map.md` chỉ có 1 cột "Dependency" free-text/story — không phải ma trận. `contract:test` không bắt được vì fixture chỉ so khớp đúng 2 chuỗi "Dependency matrix"/"Milestones" xuất hiện trong text Output, không kiểm tra có template hỗ trợ.
- **Fix:** Thêm `_refs/templates/plan/dependency-matrix.md` (lưới epic×epic hoặc team×team: loại dependency/hướng/owner) và `_refs/templates/plan/milestones.md` (milestone, ngày mục tiêu, exit criteria, owner); route cả hai từ Reference Routing.
- **Severity: P1** (cùng pattern với F-P0-1, xem ghi chú trên)

**F-P1-2 — `ship` hứa "EOL/retirement plan" nhưng không có template retirement nào**
- **File:line:** `skills/ship/SKILL.md:3` (description: "...a launch or EOL plan..."), `skills/ship/SKILL.md:8,21,22` (thân bài nhắc "retire"/"retirement" 3 lần).
- **Vấn đề → Tác động:** `_refs/templates/release/` chỉ có 2 file: `go-to-market-plan.md`, `rollout-plan.md` — không có `eol-plan.md`/`retirement-plan.md`/`sunset-plan.md` nào. Đây là gap xác nhận độc lập (tôi tự kiểm tra, không phải từ agent con), khớp với gap vòng đời "Sunset" ở Mục 5.
- **Fix:** Thêm `_refs/templates/release/eol-plan.md` (lý do retire, timeline, migration path cho user, thông báo, ngày tắt cuối, fallback/rollback nếu cần dời ngày) và route từ `ship/SKILL.md` Reference Routing.
- **Severity: P1**

**F-P1-3 — Cross-cutting: 9 file reference thiếu Good Example / Anti-pattern / Failure-modes**
- **File:line:** `_refs/workflows/change-governance.md` (16 dòng, chỉ list bước), `_refs/workflows/execution-support.md`, `_refs/workflows/experiment-design.md`, `_refs/workflows/learning-synthesis.md`, `_refs/workflows/spec-to-delivery-plan.md`, `_refs/workflows/release-readiness.md`, `_refs/workflows/product-strategy-portfolio.md`, `_refs/checklists/uat-coverage.md`, `_refs/checklists/story-quality-invest.md`.
- **Vấn đề → Tác động:** Chuẩn nội bộ (`skill-authoring.md` §6, §9) yêu cầu reference "substantial" phải có ít nhất 1 Good Example + 1 Anti-pattern + bảng Failure Modes khi ví dụ giúp làm rõ chất lượng — điều này **đã được làm tốt** ở `_refs/workflows/spec-to-design.md`, `customer-discovery-synthesis.md`, `jobs-to-be-done-analysis.md`, `ai-evaluation.md` (đủ cả 3 phần), nhưng **thiếu nhất quán** ở 9 file trên — đúng những skill có phán đoán mơ hồ nhất (phân loại minor/material change, sample-size, phân định "clarification" vs "cần change") lại thiếu ví dụ neo. Đây là gap "authoring pass không đều" chứ không phải quyết định có chủ đích.
- **Fix:** Thêm 1 Good Example + 1 Anti-pattern + bảng Failure Modes (3-4 dòng) vào cả 9 file, theo đúng khuôn đã dùng ở `spec-to-design.md`.
- **Severity: P1**

**F-P1-4 — Routing test coverage lệch: `docs`, `execution`, `memories` chỉ có positive case**
- **File:line:** `tests/fixtures/routing/skill-routing-cases.json` (docs: 2 case, cả 2 positive; execution: 2 case, cả 2 positive; memories: 2 case, cả 2 positive).
- **Vấn đề → Tác động:** Vi phạm trực tiếp `skill-authoring.md` §11 ("Positive, negative, ambiguous, handoff... cases") và Routing Gate trong `skill-quality.md` ("Negative and ambiguous cases name what must not win the route"). Bất đối xứng cụ thể: có case bảo vệ phía `knowledge`/`change` (case ambiguous/negative đặt `mustNotRouteTo: [docs]`/`[execution]`), nhưng **không có chiều ngược lại** — không case nào kiểm tra khi `docs`/`execution`/`memories` phải thắng. Một regression khiến `docs` không trigger khi cần lưu artifact, hoặc `execution` leo thang nhầm sang `change`, sẽ không bị `routing:test` phát hiện.
- **Fix:** Thêm tối thiểu mỗi skill 1 ambiguous case (docs thắng vs. memories/knowledge), 1 case execution thắng vs. change/validate, 1 case memories thắng vs. knowledge — xem case mẫu cụ thể trong báo cáo audit chi tiết của agent con (đã lưu trong transcript phiên này).
- **Severity: P1**

**F-P1-5 — ✅ Đã fix — `discovery` description dùng từ "research" trần trụi, false-positive risk với `knowledge`**
- **File:line:** `skills/discovery/SKILL.md:3`.
- **Before:** `...workshops, market sizing, business-model questions, research, or AI context design.`
- **After:** `...workshops, market sizing, business-model questions, new external market/competitor/company research, or AI context design. Use \`knowledge\` instead when the request is to retrieve or summarize facts, decisions, or research that already exist in the workspace.`
- **Vấn đề → Tác động:** "research our competitor's pricing" có thể trigger cả 2 skill tùy cách diễn đạt; routing fixture hiện tại không test riêng collision này.
- **Severity: P1**

**F-P1-6 — ✅ Đã fix (phần description; case routing bổ sung vẫn còn mở) — `knowledge` vs `memories` chồng lấn ở câu hỏi dạng "remember"**
- **File:line:** `skills/knowledge/SKILL.md:3-4,16` (Process bước 1 tự đọc `.annifity/memories/`) vs `skills/memories/SKILL.md:3`.
- **Before (knowledge):** `...Use when the user asks what exists, where it is documented, who owns it, or why a decision was made. This is read-oriented; use \`docs\` to write or index artifacts and \`memories\` to persist durable context.`
- **After (knowledge):** `...Use when the user asks what exists, where it is documented, who owns it, why a decision was made, or "what do we know/remember about X" as an open retrieval question spanning docs, memories, Jira, or Confluence. Use \`docs\` to write or index artifacts and \`memories\` only to persist new durable context or fetch one named memory record by category.`
- **Vấn đề → Tác động:** `memories` mở đầu bằng "Read and persist" nên câu hỏi dạng "what do you remember about X?" (đọc, không ghi) có thể trigger nhầm sang `memories`. Chỉ có 1 ambiguous case cho `knowledge` (test chiều ghi), 0 case cho chiều đọc/đọc.
- **Fix bổ sung:** thêm case ambiguous "What do you remember about the API rate-limit decision and why we made it?" → expected `knowledge`, `mustNotRouteTo: [memories]`.
- **Severity: P1**

**F-P1-7 — `prd` Input Contract bỏ sót `spec` như nguồn input chính (Traditional Workflow)**
- **File:line:** `skills/prd/SKILL.md:12-14`.
- **Vấn đề → Tác động:** Chỉ nêu brief/PRO/feedback/evidence/PRD cũ làm input tái sử dụng, không nêu `spec` — dù README (`_refs/workflows/prototype-first.md:40-52`) xác định "Spec is the source of truth for PRD" ở nhánh Traditional. Nhánh Traditional chỉ được mô tả ở README, **vô hình tại thời điểm trigger** vì SKILL.md không có.
- **Fix:** Thêm câu: "Reuse a confirmed `spec` as the primary source when producing a Traditional-Workflow PRD; spec is authoritative over PRD content."
- **Severity: P1**

**F-P1-8 — `prd` one-pager mode và `brief` trỏ chung 1 template, không phân biệt được**
- **File:line:** `skills/prd/SKILL.md:34` và `skills/brief/SKILL.md:41` — cả hai cùng route tới `_refs/templates/prd/one-pager.md`.
- **Vấn đề → Tác động:** Yêu cầu "write a one-pager for this feature" mơ hồ thật sự giữa 2 front-door skill khác nhau nhưng ra cùng 1 artifact; không có negative/ambiguous case bảo vệ collision cụ thể này.
- **Fix:** Hoặc cho `prd` one-pager một biến thể template riêng (thêm bảng Requirements/Decision-Authority), hoặc thêm rule + test: "one-pager không có baseline/scope xác nhận → route `brief`, không phải `prd`".
- **Severity: P1**

**F-P1-9 — Thiếu negative case cho `prd`, `spec`, `ship`, `strategy`**
- **File:line:** `tests/fixtures/routing/skill-routing-cases.json` (prd: 0 negative; spec: 0 negative; ship: 0 negative; strategy: 0 negative) — trong khi cả 4 skill đều overlap nặng với `validate`/`brief`/`plan`.
- **Fix:** mỗi skill thêm 1 negative case cụ thể (ví dụ prd → validate khi yêu cầu "review PRD trước khi baseline"; spec → brief khi yêu cầu chỉ là "định hướng trước khi khoá requirement"; ship → validate khi chỉ hỏi "sẵn sàng release chưa, chưa cần rollout plan"; strategy → plan khi yêu cầu "roadmap có mốc thời gian cho sáng kiến đã duyệt").
- **Severity: P1**

**F-P1-10 — `experiment`: sample-size template không có công thức, chỉ điền chỗ trống**
- **File:line:** `_refs/templates/experiment/sample-size.md` (routed từ `skills/experiment/SKILL.md:46`).
- **Vấn đề → Tác động:** Đây là con số quan trọng nhất, khách quan nhất trong 1 experiment (n sai lệch → quyết định go/stop sai), nhưng hiện chỉ là prose điền `[Count]`/`[Duration]`, không có công thức (baseline rate + MDE + power + alpha → n). Đây đúng là trường hợp "zero scripts by design" **sai chỗ** — nên là script/công thức, không phải phán đoán tự do.
- **Fix:** thêm công thức (vd two-proportion z-test) + ví dụ tính mẫu vào template, hoặc thêm script nhỏ dưới `tools/`.
- **Severity: P1**

**F-P1-11 — `uat`: RTM coverage là phép đếm/đối chiếu ID, hiện làm bằng prose**
- **File:line:** `_refs/templates/traceability/rtm.md:4-12` (routed từ `skills/uat/SKILL.md:39`).
- **Vấn đề → Tác động:** Coverage Summary (Total/Covered/Gaps) và chuỗi ID `REQ→STORY→AC→TC→RELEASE` là việc đếm/đối chiếu thuần túy, không phải phán đoán — ứng viên script rõ ràng nhất trong toàn repo, nhưng hiện để model tự đếm từ bảng markdown, dễ sai số âm thầm (TC-ID trỏ tới AC-ID không tồn tại, tổng không khớp số dòng).
- **Fix:** thêm `tools/check-rtm-coverage.ps1` (parse bảng RTM, xác minh mọi ID chain resolve, tự tính Total/Covered/Gap), route từ `uat` và `validate`.
- **Severity: P1**

**F-P1-12 — ✅ Đã fix — `validate` không trỏ tới script AI-eval đã có sẵn trong repo**
- **File:line:** `skills/validate/SKILL.md:53` ("Experiment and AI results" bullet).
- **Vấn đề → Tác động:** `tools/resolve-ai-evaluation-verdict.ps1` đã làm đúng việc này (parse suite JSON, áp rule threshold theo criterion/slice, tính pass/fail) nhưng không được route từ đâu ngoài file test của chính nó — trong khi `validate/SKILL.md:43,47` **đã** route tới 2 script khác (`resolve-phase-gate-approval.ps1`, `invoke-repo-doctor.ps1`) bằng path cụ thể, chứng minh cơ chế này đã tồn tại và dùng được. Không route nghĩa là model tự suy luận threshold bằng tay đúng chỗ mà `ai-evaluation-release-gate.md` cảnh báo là nguy hiểm nhất (hard-blocker slice bị "trung bình hoá" mất).
- **Fix:** thêm câu vào dòng 53: "...run the read-only `tools/resolve-ai-evaluation-verdict.ps1` against the evaluation suite to compute per-slice/per-criterion pass results before writing the verdict; never hand-derive threshold comparisons."
- **Severity: P1**

**F-P1-13 — ✅ Đã fix (phần description; case routing bổ sung vẫn còn mở) — `validate` mô tả vai trò kép ("review Annifity skill") chưa đủ phân biệt với các skill-creator khác đang có mặt trong cùng môi trường**
- **File:line:** `skills/validate/SKILL.md:3`.
- **Before:** `...Audit an existing product artifact, UX/UI design, evidence set, AI evaluation results, delivery package, or Annifity canonical skill and return a readiness or quality verdict with findings.`
- **After:** `...Audit an existing product artifact, UX/UI design, evidence set, AI evaluation results, delivery package, or an Annifity repository skill/reference file (per this repo's own skill-authoring standard, not general skill-creation guidance) and return a readiness or quality verdict with findings.`
- **Vấn đề → Tác động:** Môi trường hiện có nhiều skill "skill-creator" khác (generic) — chữ "Annifity" là điểm phân biệt duy nhất và dễ mất khi người dùng diễn đạt lại ("is this skill's trigger any good?"). Chưa có routing case nào test riêng nhánh này.
- **Severity: P1**

**F-P1-14 — Repo-level: không có `LICENSE`**
- **File:line:** root repo (không có file).
- **Vấn đề → Tác động:** `.claude-plugin/plugin.json` định vị Annifity như một plugin có thể phân phối (có `displayName`, `version`, `keywords` hướng tới marketplace), nhưng `package.json:3` khai `"private": true` — 2 tín hiệu mâu thuẫn nhau về ý định phân phối. Nếu có ý định chia sẻ/public hoá (kể cả nội bộ nhiều team), thiếu LICENSE tạo mơ hồ pháp lý khi người khác muốn dùng lại/fork.
- **Fix:** Quyết định rõ ý định phân phối; nếu có, thêm LICENSE (khuyến nghị MIT hoặc Apache-2.0 để nhất quán với 2/3 repo tham khảo).
- **Severity: P1** (nâng từ P2 vì tín hiệu plugin.json cho thấy có ý định phân phối)

### P2 — Nice-to-have

| # | File:line | Vấn đề | Fix |
|---|---|---|---|
| F-P2-1 | ~~`skills/design/SKILL.md:45-57`~~ | ✅ **Đã fix** — Không trỏ tới `_refs/operating-model/routing.md` như các skill anh em (change, discovery, execution đều trỏ) | Đã thêm dòng "For an ambiguous front door, use `_refs/operating-model/routing.md`." |
| F-P2-2 | `tests/fixtures/routing/skill-routing-cases.json` (change) | Không có handoff-case dù Handoff section của `change` rất rõ ràng | Thêm 1 case handoff-change-to-prd |
| F-P2-3 | `skills/prototype/SKILL.md:16-28` | "PRO is / PRO is not" bị lặp gần như nguyên văn ở 3 nơi (`SKILL.md`, `prototyping-requirements-one-pager.md`, `pro-quality.md`) | Gom về 1 câu trong SKILL.md, trỏ tới checklist |
| F-P2-4 | `_refs/workflows/release-readiness.md`, `_refs/workflows/product-strategy-portfolio.md` | Thiếu bảng Failure Modes (nhánh AI-only đã có, nhánh mặc định thì không) | Thêm 1-2 failure mode |
| F-P2-5 | `skills/memories/SKILL.md:3` vs `:28-30` | Description nhấn "user asks to remember" nhưng thực tế dùng chủ yếu là background pre-read trước mọi skill khác — mô tả chưa phản ánh cách dùng phổ biến nhất | Không bắt buộc sửa vì đây là internal pattern, không phải trigger ngôn ngữ tự nhiên |
| F-P2-6 | `skills/uat/SKILL.md` (thứ tự mục) | Reference Routing đặt trước Output, khác thứ tự chuẩn (`Process → Output → Reference Routing → Handoff`) — nhưng `change`, `prd` cũng vậy nên đây là inconsistency toàn repo, không riêng uat | Thống nhất lại thứ tự mục ở lần sửa tiếp theo |
| F-P2-7 | `skills/user-story/SKILL.md:16` | Mục `## Boundary` không nằm trong danh sách section được chuẩn nội bộ cho phép (chỉ cho phép thêm `Input Contract` hoặc `Decision Points`) | Đổi tên thành `Decision Points` hoặc bổ sung "Boundary" vào danh sách cho phép trong `skill-authoring.md` §5 |
| F-P2-8 | `_refs/checklists/story-quality-invest.md` | 11 dòng, không ví dụ/failure-mode, khác hẳn `acceptance-criteria-quality.md` (đầy đủ) | Thêm 1 Good/Anti-pattern example |
| F-P2-9 | ~~`skills/validate/SKILL.md:35`~~ | ✅ **Đã fix** — "Baseline-to-candidate and material-slice deltas **when applicable**" — nhưng `ai-evaluation-release-gate.md` coi đây là bắt buộc, không phải optional | Đã sửa thành "required whenever an AI evaluation is the target" |
| F-P2-10 | ~~`skills/brief/SKILL.md:3`~~ | ✅ **Đã fix** — Description không nêu `discovery` như hàng xóm cần phân biệt (dù thân bài có xử lý đúng) | Đã thêm "Use `discovery` first when the problem, users, or outcome are still unconfirmed." vào đầu câu 2 |
| F-P2-11 | Repo root | Không có `CONTRIBUTING.md` | Không cấp thiết nếu vẫn là repo nội bộ 1 người; cần nếu mở rộng contributor |

---

## 5. Gap Analysis — Phủ Vòng Đời Sản Phẩm

| Giai đoạn | Annifity đã có | Repo tham khảo có | GAP |
|---|---|---|---|
| **Discovery** | `discovery` skill; workflows: `customer-discovery-synthesis`, `jobs-to-be-done-analysis`, `research-evidence`, `solution-exploration`, `market-sizing`, `workshop-facilitation` | Repo 1: `jobs-to-be-done`, `discovery-process`, `discovery-interview-prep`, `problem-framing-canvas`, `problem-statement` là các skill **độc lập** (không gộp vào 1 skill lớn) | Không gap về nội dung; khác biệt kiến trúc (Annifity gộp vào 1 front-door + nhiều reference, repo 1 tách thành nhiều skill nhỏ) — xem đánh đổi ở Mục 6 |
| **Strategy/Positioning** | `strategy` skill; templates: `product-strategy`, `portfolio-decision`, `business-model-canvas`, `market-sizing`, `opportunity-solution-tree`, `stakeholder-decision-map`, `company-research-brief`, **`positioning-statement` (mới, đã đóng gap)** | Repo 1: `positioning-statement`, `positioning-workshop` (Geoffrey Moore) là skill/template **riêng biệt và chi tiết** | ✅ **Đã đóng** — thêm `_refs/templates/strategy/positioning-statement.md` (khung Geoffrey Moore: For/Who/The/That/Unlike/Our), route từ `strategy/SKILL.md` Reference Routing |
| **Roadmap** | `plan` skill; `_refs/templates/plan/product-roadmap.md` (Now/Next/Later), **`milestones.md` + `dependency-matrix.md` (mới, đã đóng gap)** | Repo 1: `roadmap-planning` (skill riêng) | ✅ **Đã đóng (F-P1-1)** — thêm `_refs/templates/plan/milestones.md` (lịch mốc + exit criteria + owner) và `_refs/templates/plan/dependency-matrix.md` (ma trận dependency 2 chiều), route từ `plan/SKILL.md` |
| **Spec/PRD** | `spec` + `prd`; rất đầy đủ (workflow-spec, data-requirements, api-contract, default-prd, confluence-html...) | Repo 1: `prd-development` (1 skill, ít chi tiết hơn Annifity) | Annifity **vượt trội** ở giai đoạn này — không gap |
| **UX/Design** | `design` skill; templates: `design-system` (**nay đã có 3 lớp: Primitive → Semantic → Component**), `interaction-state-matrix`, `screen-spec`, `design-handoff`, `design-traceability`, `portable-html.html` (**nay đã tương tác thật: chuyển tab màn hình, toggle state loading/empty/error/success, validate form mẫu — thuần vanilla JS/CSS, không network call, đã test bằng click thật trong browser**) | Repo 2 (ui-ux-pro-max): kiến trúc token 3 lớp (Primitive → Semantic → Component) + database CSV màu/font/component có thể search bằng script; Repo 3 (stitch-skills): pipeline spec→design-system→generate→iterate→code, có AST-based validation cho code sinh ra | 🟡 **Đóng phần lớn** — 3-lớp token ✅, HTML preview giờ click được (tab + state toggle + form validation mẫu) ✅. **Còn mở theo quyết định của bạn (chưa làm, cần MCP mới):** cơ chế search/database CSV+script kiểu ui-ux-pro-max, và pipeline tự sinh code React/screenshot thật kiểu repo 2/3 — xem Mục 6 #7 |
| **Delivery/Sprint** | `plan`, `user-story`, `execution`; đầy đủ INVEST, Given/When/Then, epic map | Repo 1: `user-story-mapping`, `user-story-splitting`, `epic-breakdown-advisor`, `epic-hypothesis` (tách nhỏ hơn) | Không gap nội dung — khác biệt kiến trúc (gộp vs tách) |
| **Launch/GTM** | `ship`; `_refs/templates/release/go-to-market-plan.md`, `_refs/workflows/go-to-market-adoption.md` | — | Đầy đủ |
| **Metrics/Analytics** | `_refs/checklists/finance-metrics.md` (**nay đã có mục `## Formulas`**: MRR/ARR/ARPU/NRR/Quick Ratio/CAC/LTV/LTV:CAC/Payback/Rule of 40/Magic Number/Gross Margin), `ai-unit-economics.md`, `metric-tree.md`, `product-analytics-review.md` | Repo 1: `saas-revenue-growth-metrics`, `saas-economics-efficiency-metrics`, `finance-metrics-quickref` (tách biệt, sâu hơn về tài chính SaaS) | ✅ **Đã đóng** — sau khi đọc lại toàn văn `finance-metrics.md`, tên các metric (NRR, LTV:CAC, Rule of 40...) **đã có sẵn** trong bảng Metric Families/Red Flags; gap thật sự chỉ là thiếu **công thức tính**, nay đã bổ sung. Không tạo file mới để tránh trùng lặp (vi phạm Reference Gate của chính repo) |
| **Iteration** | `learn` skill; `_refs/workflows/learning-synthesis.md`, templates insight-summary/decision-memo/product-retrospective | — | Đầy đủ về mặt front-door, nhưng thiếu example/failure-modes (F-P1-3, chưa làm) |
| **Sunset** | `ship` (description hứa "retirement"/"EOL plan"), **`_refs/templates/release/eol-plan.md` (mới, đã đóng gap)** | Môi trường hiện tại có sẵn skill `99be43c842d3:eol-message` (viết thông báo EOL) làm ví dụ tham khảo mẫu | ✅ **Đã đóng (F-P1-2)** — thêm `_refs/templates/release/eol-plan.md` (retirement scope, customer impact/migration, timeline, communications, rollback-or-extend, post-retirement review), route từ `ship/SKILL.md`, và thêm dòng "EOL/retirement plan" vào Output của `ship` |

---

## 6. Skill/Reference Đề Xuất Bổ Sung

Theo đúng nguyên tắc "Extension Guidelines" của chính README (`README.md:231-253`): **ưu tiên thêm reference vào skill có sẵn, chỉ tạo skill mới khi có trigger khác biệt thật sự**. Vì vậy hầu hết đề xuất dưới đây là **reference bổ sung**, không phải skill mới — tạo skill mới cho "positioning" hay "GTM metrics" sẽ vi phạm chính quy tắc §2 của `skill-authoring.md` (skill-vs-reference decision).

| # | Đề xuất | Loại | Vị trí | Học pattern từ | Trạng thái |
|---|---|---|---|---|---|
| 1 | `_refs/templates/strategy/positioning-statement.md` | Reference | route từ `strategy/SKILL.md` | Repo 1 (`positioning-statement`, Geoffrey Moore template) | ✅ Đã làm |
| 2 | `_refs/templates/plan/dependency-matrix.md` + `_refs/templates/plan/milestones.md` | Reference | route từ `plan/SKILL.md` | — (tự thiết kế theo gap F-P1-1) | ✅ Đã làm |
| 3 | `_refs/templates/release/eol-plan.md` | Reference | route từ `ship/SKILL.md` | — (tự thiết kế theo gap F-P1-2) | ✅ Đã làm |
| 4 | Mở rộng `_refs/templates/design/design-system.md` thêm lớp "Primitive" (raw token trước khi map sang semantic) | Reference (sửa file có sẵn) | `design/SKILL.md` | Repo 2 (ui-ux-pro-max: Primitive → Semantic → Component) | ✅ Đã làm |
| 5 | ~~`_refs/checklists/saas-benchmark-metrics.md`~~ (đổi kế hoạch — xem cột Trạng thái) | Reference | `strategy/SKILL.md` và `validate/SKILL.md` (đã có route sẵn) | Repo 1 (`saas-revenue-growth-metrics`, `saas-economics-efficiency-metrics`) | ✅ Đã làm khác đi: không tạo file mới (metric names đã tồn tại trong `finance-metrics.md`, tạo file mới sẽ trùng lặp) — thay vào đó bổ sung mục `## Formulas` vào `finance-metrics.md` có sẵn |
| 6 | `tools/check-rtm-coverage.ps1` (script) | Script | route từ `uat/SKILL.md`, `validate/SKILL.md` | Repo 2/3 (deterministic validation scripts: `validate.js` AST check, `validate_data.py`) | ⬜ Chưa làm — thuộc nhóm Ngắn hạn (F-P1-11), không phải Gap Analysis Mục 5 |
| 7a | `_refs/templates/design/portable-html.html` — thêm tương tác thật (tab chuyển màn hình, toggle state, form validation mẫu) bằng vanilla JS/CSS, không MCP/dependency mới | Asset (sửa file có sẵn) | đã route sẵn ở `design/SKILL.md:52` | Ý tưởng "interactive-html" đã có sẵn trong `tools/new-design-package.ps1` (là **giá trị mặc định** của `-Mode`, 1 trong 4 mode hợp lệ) nhưng chưa từng có nội dung tương tác thật — đóng đúng khoảng cách đó | ✅ Đã làm — test bằng click thật trong browser (chuyển tab, chuyển state, submit form rỗng → báo lỗi, điền lại → báo thành công), không lỗi console, không gọi mạng; `npm run check` xanh toàn bộ |
| 7b | Cơ chế search/database CSV+script kiểu ui-ux-pro-max, và pipeline tự sinh code React/screenshot thật (MCP builder + Playwright) kiểu repo 2/3 | Workflow mới trong `_refs/workflows/` + data/script mới + MCP integration | route có điều kiện từ `prototype/SKILL.md`/`design/SKILL.md` | Repo 2 (shadcn MCP build + Playwright MCP screenshot + design-review subagent), Repo 3 (Stitch MCP generate + baton loop) | ⬜ **Cố ý chưa làm** — khác 7a ở chỗ này cần MCP server bên ngoài (shadcn/Playwright/Stitch), là quyết định kiến trúc/phạm vi sản phẩm thật sự, không phải chỉ thêm asset. Cần bạn xác nhận có sẵn MCP server tương ứng trước khi làm |

**Không đề xuất tạo skill mới nào** — 19 front-door hiện tại đã phủ đủ trigger phân biệt được theo đúng bài test skill-vs-reference của chính repo. Việc thêm reference/template ở trên đủ để lấp các gap đã xác nhận mà không phá vỡ kiến trúc "front-door gọn" mà Annifity đang cố giữ.

---

## 7. Token Optimization Plan

| # | Đề xuất | Token tiết kiệm ước tính | Trade-off |
|---|---|---|---|
| 1 | Rút gọn description của `validate` (162 token, dài nhất) và `discovery` (160 token, nhì) xuống ~120 token mỗi cái bằng cách bỏ liệt kê trùng lặp, giữ nguyên phần phân biệt ranh giới | ~80 token (thường trực, mọi phiên) | Thấp — chỉ cắt phần liệt kê dư, không cắt phần disambiguation |
| 2 | Áp dụng F-P1-5, F-P1-6, F-P2-10, F-P1-13 (4 description cần **thêm** chữ để giảm misroute) | **-100 token** (tăng, không giảm) | **Đánh đổi ngược lại token để giảm rủi ro misroute** — nên làm dù tốn thêm ~100 token, vì chi phí 1 lần misroute (phải làm lại cả 1 artifact) lớn hơn nhiều 100 token |
| 3 | Gộp "PRO is/is not" list (F-P2-3) từ 3 bản sao còn 1 bản | ~250-400 token **mỗi lần `prototype` trigger** (không phải chi phí thường trực — chỉ tiết kiệm khi skill được load) | Không đáng kể ở quy mô toàn phiên, nhưng giảm rủi ro 2 bản lệch nhau theo thời gian |
| 4 | Không nén `tools/`, `.annifity/`, `tests/`, `docs/` | 0 (không có gì để tiết kiệm — agent không bao giờ load các thư mục này trong vận hành bình thường) | — |
| 5 | Đặt ngưỡng chuẩn cho repo: description ≤ 120 từ (hiện có 2 skill vượt: `discovery` 88 từ — **chưa vượt**, `validate` 91 từ — **chưa vượt**; thực ra không skill nào vượt 100 từ) | 0 — đã đạt chuẩn | Kết luận: **description hiện tại đã đủ gọn**, không cần cắt lớn |
| 6 | SKILL.md body ≤ 500 dòng (chuẩn skill-creator) | 0 — skill dài nhất (`prototype`) chỉ 75 dòng | Đã đạt chuẩn với biên độ rất lớn (85% dưới ngưỡng) |

**Kết luận Token Optimization:** Annifity đã tối ưu token tốt hơn phần lớn skill repo nhờ kiến trúc `_refs/` dùng chung + progressive disclosure triệt để. Không có "quick win" giảm token lớn (vì không có gì to để cắt) — hành động đúng đắn ở đây là **ưu tiên độ chính xác trigger hơn vài chục token**, và dọn dẹp 1 chỗ trùng lặp nội dung (PRO list) để giảm rủi ro drift, không phải để tiết kiệm token.

---

## 8. Roadmap Thực Thi

### Quick wins (< 1 giờ) — ✅ Đã hoàn thành toàn bộ
- [x] F-P1-5, F-P1-6, F-P1-13, F-P2-10: sửa 4 description theo before/after đã viết sẵn ở Mục 4
- [x] F-P2-1: thêm 1 dòng route tới `routing.md` trong `design/SKILL.md`
- [x] F-P2-9: sửa "when applicable" → "required whenever..." trong `validate/SKILL.md:35`
- [x] F-P1-12: thêm 1 câu route tới `resolve-ai-evaluation-verdict.ps1` trong `validate/SKILL.md:53`
- [x] `npm run check` xanh toàn bộ sau khi sửa (phát hiện và tự sửa 1 fixture routing bị vỡ do đổi câu chữ `brief`)

### Gap Analysis (Mục 5) — ✅ Đã đóng 4/5 gap, 1 gap đóng một phần theo lựa chọn phạm vi của bạn
- [x] Positioning: thêm `_refs/templates/strategy/positioning-statement.md`, route từ `strategy/SKILL.md`
- [x] Roadmap: thêm `_refs/templates/plan/milestones.md` + `dependency-matrix.md`, route từ `plan/SKILL.md`
- [x] Sunset: thêm `_refs/templates/release/eol-plan.md`, route từ `ship/SKILL.md`, thêm dòng Output tương ứng
- [x] Metrics: thêm mục `## Formulas` vào `_refs/checklists/finance-metrics.md` có sẵn (không tạo file trùng lặp)
- [x] Design (một phần): thêm lớp `## Primitives` + cột "Maps to primitive" vào `_refs/templates/design/design-system.md`
- [ ] Design (phần còn lại, cố ý chưa làm theo lựa chọn của bạn): cơ chế search/database CSV+script và bước sinh mockup+screenshot+review — xem Mục 6 #7, cần quyết định phạm vi sản phẩm riêng
- [x] `npm run check` xanh toàn bộ sau khi thêm 4 file mới (`ref:check` xác nhận 233/233 file `_refs/` có route hợp lệ, không orphan)

### Ngắn hạn (1 tuần) — chưa làm, còn nguyên trong roadmap
- [ ] F-P0-1, F-P1-1, F-P1-2: đồng bộ lại 3 cặp SKILL.md/template bị "template drift" (`spec`, `plan`, `ship`) — ưu tiên cao nhất vì đây là nhóm ảnh hưởng chất lượng output thật (lưu ý: F-P1-1 và F-P1-2 nay đã có template hỗ trợ nhờ Gap Analysis ở trên, nhưng `spec` — F-P0-1 — vẫn còn mở)
- [ ] F-P1-4: viết thêm routing case cho `docs`/`execution`/`memories` (mỗi skill tối thiểu 1 negative + 1 ambiguous)
- [ ] F-P1-9: thêm negative case cho `prd`/`spec`/`ship`/`strategy`
- [ ] F-P1-6, F-P1-13 (phần còn lại): thêm routing case ambiguous cho collision `knowledge`/`memories` và `validate` dual-role
- [ ] F-P1-3: thêm Good Example + Anti-pattern + Failure Modes cho 9 file reference đã liệt kê (có thể chia nhỏ theo skill, làm dần)
- [ ] F-P1-10, F-P1-11: thêm công thức sample-size và script RTM coverage
- [ ] Quyết định về LICENSE (F-P1-14) — cần input từ chủ repo, không phải quyết định kỹ thuật thuần túy

### Dài hạn
- [ ] Đề xuất Mục 6 #6: `tools/check-rtm-coverage.ps1` (script RTM coverage)
- [ ] Đề xuất Mục 6 #7 (mockup sinh thật + screenshot review + search/database token) — chỉ nên làm nếu Annifity muốn mở rộng phạm vi từ "đặc tả design" sang "sinh mockup trực quan", đây là quyết định phạm vi sản phẩm, không phải fix kỹ thuật
- [ ] Rà soát định kỳ (mỗi quý) bằng `validate` skill của chính repo, dùng rubric Mục 2 làm checklist

---

*Ghi chú phương pháp: audit này chạy trực tiếp 6 lệnh validate của repo (`guard`, `skill:validate`, `ref:check`, `routing:test`, `contract:test`, `sync:check` — tất cả PASS tại thời điểm audit), đọc toàn bộ 19 `SKILL.md`, đọc trực tiếp các file `_refs/operating-model/*.md` liên quan, phân tích file `tests/fixtures/routing/skill-routing-cases.json` bằng script, và dùng 5 sub-agent độc lập (4 audit skill theo nhóm + 1 nghiên cứu 3 repo tham khảo) để tăng độ phủ mà không làm phình context. Không có phần nào trong báo cáo này được suy đoán khi không thể xác minh — nếu 1 claim không kiểm chứng được, nó không xuất hiện ở đây.*
