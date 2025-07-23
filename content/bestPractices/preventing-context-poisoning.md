# Preventing Context Poisoning

GitHub Copilot gets confused when you mix tasks in one chat, leading to strange suggestions, like giving someone mixed directions they keep following.

## How Confusion Starts

A common mistake is to ask Copilot **to perform different kinds of tasks back-to-back in the same chat**.

Here’s an example of how this confusion can happen step-by-step:

1. First, you ask Copilot to help you **change a piece of code**.
2. Immediately after, you ask it to **deploy the changes**.
3. You repeat this sequence a few times.
4. Copilot forms a pattern: **"Code changes are always followed by deployment."**
5. Later, when you ask it to change different code,**even just for testing, it may still suggest deployment steps** because it's following the learned pattern.

Copilot sees all open files and remembers the entire chat. Mixing topics or tasks without clear transitions confuses it, especially in long, complex sessions.

## Common Ways Copilot Gets Confused

- **Task Bleeding:** Previous task context leaks into new work (e.g., Python patterns in JavaScript files)
- **Instruction Overload:** Multiple requests in one prompt dilute focus and quality
- **Conflicting Rules:** Contradictory instructions (e.g., "always test" vs "skip tests") create paralysis
- **Stale Context:** Outdated information from earlier in the chat influences current suggestions

## How to Fix It and Stop It from Happening

Here are some simple tricks to keep Copilot on the right track and to fix it when it gets confused:

- **Use a new chat for a new job.** When working on something completely different, it's best to start a fresh chat.
- **Start over when it gets confused.** If Copilot starts acting weird, just create a new chat to wipe the slate clean.
- **Announce when switching topics.** A simple message like, "Okay, done with the database. Now working on the website's design," can make a huge difference.
- **Keep instructions neat.** Use formatting like code blocks to clearly separate instructions from the code being discussed.
- **Be very clear about what is needed.** Don't assume Copilot knows what is meant. Spell it out.
- **Quickly review the past chat.** Every so often, look back at the conversation to see if any confusing patterns might have been accidentally created.

Clean chat context is clean code. Messy prompts yield messy AI output. Confusion often stems from polluted context.
