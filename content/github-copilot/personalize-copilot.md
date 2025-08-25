# Personalize Copilot

## Setup AI Instructions (workspace) in VS Code

1. create a markdown file named as `.github/copilot-instructions.md` in the project root directory.
2. write down your prompts, rules and instructions in natural language in the instruction file.

## Setup AI Instructions (by file entension) in VS Code

1. Create an instruction file by pressing `ctl+alt+/` (in Windows)

2. Choose `instructions` to create a new instruction file in `.github/instructions`

3. Name the instruction file (e.g. spring-boot)

4. Instruction file is created in `.github/instructions/spring-boot.instructions.md`

5. Write down the prompts in natural language. Code fences are used to tell the following prompts are only applied to specified file types. (e.g. `**/*.java` is only applied to java files. Whenever copilot is going to work with java files, the prompts are injected in the chat.)

:::note
Keep your instructions concise and precise. Poor instructions can degrade Copilot's quality and performance.
:::
