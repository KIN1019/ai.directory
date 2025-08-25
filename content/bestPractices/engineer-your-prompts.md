# Engineer Your Prompts

Prompt engineering is the art of crafting effective inputs for AI models to get the best possible results. Just like with traditional programming, the quality of your input directly impacts the quality of the output. This guide provides principles and techniques to help you write better prompts.

## General principles

The following are some core principles that apply to most prompt engineering tasks. They are designed to help you get more accurate, relevant, and useful responses from the AI.

### Be explicit with your instructions

Agents respond effectively to clear and explicit instructions. Specifying your desired output can significantly enhance results. To achieve "above and beyond" behavior, it may be necessary to explicitly request these actions.

Less effective:

```text
Create an analytics dashboard
```

More effective:

```text
Create an analytics dashboard.
Include as many relevant features and interactions as possible.
Go beyond the basics to create a fully-featured implementation.
```

---

### Add context to improve performance

Providing context or motivation behind your instructions, such as **explaining to the agent why** such behavior is important, can help the agent better understand your goals and deliver more targeted responses.

Less effective:

```
NEVER use ellipses
```

More effective:

```
Your response will be read aloud by a text-to-speech engine,
so never use ellipses since the text-to-speech engine will
not know how to pronounce them.
```

Claude is smart enough to generalize from the explanation.

---

### Be careful with examples & details

Agents pay attention to details and examples as part of instruction following.
Ensure that your examples align with the behaviors you want to encourage and
minimize behaviors you want to avoid.

---

### Avoid focusing on passing tests and hard-coding

Frontier language models can sometimes focus too heavily on making tests pass at the expense of more general solutions. To prevent this behavior and ensure robust, generalizable solutions:

```
Please write a high quality, general purpose solution.
Implement a solution that works correctly for all valid inputs, not just the test cases.
Do not hard-code values or create solutions that only work for specific test inputs.
Instead, implement the actual logic that solves the problem generally.

Focus on understanding the problem requirements and implementing the correct algorithm.
Tests are there to verify correctness, not to define the solution.
Provide a principled implementation that follows best practices and software design principles.

If the task is unreasonable or infeasible, or if any of the tests are incorrect,
please tell me. The solution should be robust, maintainable, and extendable.
```

## Specific principles

While the general principles provide a solid foundation, the following specific techniques can help you address more nuanced scenarios and gain finer control over the AI's output.

### Tell the agent DO instead of DON'T in steering output formatting

Less effective:

```
Do not use markdown in your response
```

More effective:

```
Your response should be composed of smoothly flowing prose paragraphs.
```

---

### Leverage thinking & interleaved thinking capabilities

Some models, like Claude 4, offers thinking capabilities that can be especially helpful for tasks involving reflection after tool use or complex multi-step reasoning. You can guide its initial or interleaved thinking for better results.

```
After receiving tool results, carefully reflect on their quality and
determine optimal next steps before proceeding.
Use your thinking to plan and iterate based on this new information,
and then take the best next action.
```

---

### Enhance visual and frontend code generation

For frontend code generation, you can steer some models, like Claude 4, to create complex, detailed, and interactive designs by providing explicit encouragement:

```
Don't hold back. Give it your all.
```

You can also improve Claude’s frontend performance in specific areas by providing additional modifiers and details on what to focus on:

- "Include as many relevant features and interactions as possible"
- "Add thoughtful details like hover states, transitions, and micro-interactions"
- "Create an impressive demonstration showcasing web development capabilities"
- "Apply design principles: hierarchy, contrast, balance, and movement"
  ​

---

### Reduce file creation in agentic coding

Agents may sometimes create new files for testing and iteration purposes, particularly when working with code. This approach allows the agent to use files, especially python scripts, as a ‘temporary scratchpad’ before saving its final output. Using temporary files can improve outcomes particularly for agentic coding use cases.

If you’d prefer to minimize net new file creation, you can instruct the agent to clean up after itself:

```
If you create any temporary new files, scripts, or helper files for iteration, clean up these files by removing them at the end of the task.
```
