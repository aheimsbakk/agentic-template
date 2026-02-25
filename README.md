# 🚀 OpenCode Multi-Agent Workflow

Welcome to your autonomous AI development team. Instead of relying on a single AI to do everything, this setup provides you with a team of specialized agents. Each agent has a specific job—from brainstorming ideas to writing code and running tests. 

This template is designed to keep your project organized, your architecture clean, and your codebase bug-free.

---

## ⬇️ Quick Install

Install the agentic template scripts and helpers. From the root of your project you can fetch and run the installer directly from the template repository with:

```bash
curl -fsSL https://raw.githubusercontent.com/aheimsbakk/agentic-template/main/agents/update-agents.sh | bash
```

To update the local scripts later (run this from the root of your repo):

```bash
./agents/update-agents.sh
```

Security tip: review the downloaded script before piping to bash. To download without executing first:

```bash
curl -fsSL https://raw.githubusercontent.com/aheimsbakk/agentic-template/main/agents/update-agents.sh | less
```

## 👥 Meet the Team

You have two primary ways to interact with the system, depending on what you need:

**1. The Primaries (Your Chat Partners)**
* 🧠 **Brainstorm:** Your creative sounding board. Talk to this agent when you want to explore new features, find logical flaws in your ideas, or discuss architecture. It won't write code; it will help you think.
* 🤝 **Vibe:** Your interactive pair-programmer. Use this for quick, hands-on coding sessions where you want to work together step-by-step. 
* 📋 **Plan:** The built-in planning agent for structuring broader goals.

**2. The Factory (The Autonomous Subagents)**
When you have a solid idea and want the system to build it autonomously, you hand it over to the Factory.
* 👔 **PM (`@pm`):** The Project Manager. You give it a task, and it orchestrates the rest of the team. It does not write code—it routes tasks.
* 📐 **Architect (`@architect`):** Plans the file structure and updates the system blueprints.
* 👷 **Builder (`@builder`):** Writes the actual code and features.
* 🕵️ **QA (`@qa`):** Tests the code, reads error logs, and performs the final Git commit.

---

## 🔄 How the Autonomous Pipeline Works

When you have agreed on an idea with the **Brainstorm** or **Plan** agent, you trigger the autonomous pipeline by tagging the Project Manager (`@pm`). 

Here is what happens behind the scenes while you sit back and watch:

```text
[ You ] 
   │
   ▼
[ @brainstorm / @plan ] ──(Discuss ideas & finalize a Project Brief)
   │
   ▼  Trigger: "@pm, build this brief ... a copy of the brief"
┌────────────────────────────────────────────────────────┐
│ 👔 PROJECT MANAGER (@pm)                               │
│ (The Orchestrator. Routes tasks, never writes code)    │
└─────────┬──────────────────────────────────────────────┘
          │
  1. Plan │
          ▼
      [ 📐 Architect ] <───────┐ 
          │                    │ 
  2. Build│                    │ 4B. Logic Flaw 
          ▼                    │    (Revise Plan)
      [ 👷 Builder ] ──────────┘
          │      ▲
  3. Test │      │ 4. QA Failed 
          ▼      │   (Fix Code)
      [ 🕵️ QA ] ─┘
          │
  5. Pass │
          ▼
   🎉 DONE! (Final Git Commit & User Summary)
```

### The PM's State Machine Logic:
1. **Plan:** PM asks the Architect to figure out *how* to build your idea.
2. **Build:** PM passes the Architect's plan to the Builder, who writes the code.
3. **Test:** PM asks QA to test the Builder's code.
4. **Fix (If needed):** If QA finds an error, PM sends the error log back to the Builder to fix it. This loops until the tests pass (max 3 times).
5. **Logic Flaw:** If the Builder encounters impossible logic, the PM sends the task back to the Architect to revise the plan.
6. **Finish:** Once QA approves, the code is committed, and PM gives you a short summary of the result.

---

## 🛠️ How to Use the System

### Workflow A: The Autonomous Factory (Recommended for new features)
Use this workflow when you want a feature built from start to finish with proper testing and documentation.

1. **Discuss:** Start a chat with `brainstorm`. Explain what you want to achieve.
2. **Refine:** Answer Brainstorm's critical questions until the idea is solid.
3. **Trigger:** Once Brainstorm generates a "Project Brief", simply tag `@pm` and tell it to execute the brief (e.g., *"@pm, please build the brief we just discussed"*).
4. **Wait:** Do not interrupt the PM while it calls the Architect, Builder, and QA. 
5. **Review:** When QA passes, the PM will give you a quick summary. 

*💡 Pro-Tip: To keep the AI's memory sharp, it's highly recommended to start a **New Chat** for each new major feature before calling `@pm`.*

### Workflow B: Vibe Mode (Recommended for quick fixes)
Use this workflow when you want to quickly debug an issue or write code collaboratively without the heavy process.

1. **Start:** Chat with **Vibe**.
2. **Code:** Ask it to read logs, run tests, or write snippets directly.
3. **Wrap up:** When you are satisfied, simply tell Vibe to "wrap up", and it will automatically document the changes and commit your code.

---

## 📂 Important Files to Know
The agents rely on a few critical markdown files to stay synchronized. The Architect will update `BLUEPRINT.md`, `CONTEXT.md` and `docs/PROJECT_RULES.md` automatically, but you should know they exist:

* `AGENTS.md`: The master rulebook for how the agents behave and commit code.
* `BLUEPRINT.md`: The high-level map of your system's architecture and data models.
* `CONTEXT.md`: A short summary of the project's current state.
* `agents/RULES.md`: Absolute, unbreakable rules for the project.
* `docs/PROJECT_RULES.md`: Dynamic coding conventions deduced by the Architect. 

Enjoy building with your new autonomous team!
