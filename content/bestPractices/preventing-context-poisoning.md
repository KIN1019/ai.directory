# Preventing Context Poisoning

GitHub Copilot gets confused when you mix tasks in one chat, leading to strange suggestions, like giving someone mixed directions they keep following.

## How Confusion Starts

When you **mix different types of tasks in a single Copilot chat**, like switching between code changes and deployments, **Copilot can learn false patterns and get confused**. This is called context poisoning, where it starts applying the wrong actions in new situations. The following diagram demonstrates this problem:

<img src="/images/context-poisoning.png" alt="Diagram illustrating context poisoning: An AI learns a false pattern from a user's repeated commands and incorrectly applies it in a new situation." width="60%" style="margin: auto"/>

In the **Polluted Context** example, the AI incorrectly learns from the single chat that code changes are always followed by deployment. It then wrongly applies this pattern when asked for a test-only change.

**Separate Chats** create a clean context for each task, preventing these false associations and ensuring the AI only performs the requested action.

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

> Clean chat context is clean code.  
> Messy prompts yield messy AI output.  
> Confusion often stems from polluted context.
