# HappyHour
**A daily standup tool**

![Screenshot](Screenshot.png)

This is a small application for MacOS that may help you keep track of notes for your daily standup. Especcially if your standups are conducted asynchronously via Email, Slack, etc.

The screenshot above will produce a message ready to paste into your standup thread:

> **Today:**
> ✅ Rewrite some code PR-123
> ✅ Fix that annoying bug BUG-4 PR-124
> **Tomorrow:**
> ➡️ Out on holiday tomorrow
> **QBI:**
> ⁉️ I'm blocked waiting for answers from QA on BUG-7

## Features
* Sections for planning, today, tomorrow, questions/blockers/interesting
* Auto-linking to pull requests and Jira issues
* Drag items to reorder, and between sections
* Customizable reset behavior. By default, anything set for "Tomorrow" becomes "Planned"

## Build
1. Open the xcode project (Big sur required)
2. Build and run
