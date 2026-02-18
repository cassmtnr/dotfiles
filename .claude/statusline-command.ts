#!/usr/bin/env bun

import { execSync } from "child_process";
import { basename } from "path";
import { userInfo } from "os";

interface StatusInput {
  cwd?: string;
  session_id?: string;
  session_name?: string;
  workspace?: {
    current_dir?: string;
  };
  context_window?: {
    remaining_percentage?: number;
  };
  model?: {
    display_name?: string;
  };
}

const c = {
  reset: "\x1b[0m",
  cyan: "\x1b[36m",
  magenta: "\x1b[35m",
  blue: "\x1b[34m",
  green: "\x1b[32m",
  yellow: "\x1b[33m",
  red: "\x1b[31m",
};

function getGitBranch(): string | null {
  try {
    return execSync("git branch --show-current 2>/dev/null", {
      encoding: "utf-8",
    }).trim() || execSync("git rev-parse --short HEAD 2>/dev/null", {
      encoding: "utf-8",
    }).trim() || null;
  } catch {
    return null;
  }
}

function contextColor(remaining: number): string {
  if (remaining < 20) return c.red;
  if (remaining < 50) return c.yellow;
  return c.green;
}

const input: StatusInput = JSON.parse(await Bun.stdin.text());

const cwd = input.workspace?.current_dir ?? input.cwd ?? "";
const project = basename(cwd);
const username = userInfo().username;
const sessionId = input.session_id;
const sessionName = input.session_name;
const remaining = input.context_window?.remaining_percentage;
const model = input.model?.display_name;

// Line 1: project on branch
let line1 = "";
if (process.env.SSH_CONNECTION) {
  line1 += `${c.blue}${username}${c.reset} `;
}
line1 += `${c.cyan}${project}${c.reset}`;

const branch = getGitBranch();
if (branch) {
  line1 += ` on ${c.magenta}🌱 ${branch}${c.reset}`;
}

// Line 2: session + context + model
const parts: string[] = [];
if (sessionId) {
  parts.push(sessionName
    ? `${c.magenta}${sessionName} · sid: ${sessionId}${c.reset}`
    : `${c.magenta}sid: ${sessionId}${c.reset}`);
}
if (remaining != null) {
  parts.push(`${contextColor(remaining)}[ctx: ${Math.round(remaining)}%]${c.reset}`);
}
if (model) {
  parts.push(`[${c.cyan}${model}${c.reset}]`);
}

console.log(line1);
process.stdout.write(parts.join(" "));
