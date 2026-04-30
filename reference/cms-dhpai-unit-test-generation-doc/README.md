# Copilot Unit Test Generation Guide

### Verification Required

All code generated should be thoroughly reviewed and tested before implementation. The AI may not account for specific project requirements or environments.

---

### Overview

This guide provides step-by-step instructions for automatically generating unit tests for Spring Boot projects using GitHub Copilot Chat in Visual Studio Code. The approach is specifically optimized for SonarQube analysis to ensure systematic and thorough test coverage.

**Key Benefits**

- **Saving time on routine tasks**: Offload much of the grunt work
- **Automated Test Generation**: Leverage AI to create comprehensive unit tests
- **Quality Assurance**: Ensure robust error handling and edge case testing

---

### Prerequisites

**IDE and Copilot Proxy Setup**

- [IDE Setup - Visual Studio Code](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/Source_Control/GitHub/GitHub_Copilot/Copilot_Setup/IDE_Setup_-_Visual_Studio_Code.html)
- [IDE Setup - IntelliJ IDEA](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/Source_Control/GitHub/GitHub_Copilot/Copilot_Setup/IDE_Setup_-_IntelliJ_IDEA.html)

**Visual Studio Code**

- Version 1.102 or above required
- Latest version recommended for optimal performance

**GitHub Copilot Chat**

- Ensure Agent Mode is enabled for code editing
- If unavailable, enable by setting \`chat.agent.enabled\` in VS Code settings (Ctrl + ,)![Picture4](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/82e61be0-6d77-4003-874c-ab171ea490cf)
- Enable auto-approval `chat.tools.autoApprove` in VS Code settings (Ctrl + ,)![Picture6](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/9f64a154-6f3f-4b4b-84fb-23a7751626a7)
- [**For VS Code version v1.104.0**] Enable Global Auto Approve `global.auto.approve` in VS Code settings (Ctrl + ,)![Picture9](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/3945e828-13e7-4f76-bb52-90b7516c8e41)
- Set `Max Requests` to 999 in VS Code settings (Ctrl + ,)![Picture5](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/5229a282-4435-4db7-8f99-e8a52620209e)
- Start a new Copilot Chat session before running unit test generation

**LLM Model Suggestion**

- **Recommended**: Use **Claude Sonnet 4.5**
- For **GPT-4.1**, please reference to [cms-dhpai-copilot-booster-doc](https://hagithub.home/CMS/cms-dhpai-copilot-booster-doc)

**JaCoCo Plugin Configuration**

1.  Open your project's \`pom.xml\` file
2.  Verify the JaCoCo Maven plugin is present
3.  If missing, add the JaCoCo plugin configuration

**Example JaCoCo Plugin Configuration:**

```
<build>
  <plugins>
    <plugin>
      <groupId>org.jacoco</groupId>
      <artifactId>jacoco-maven-plugin</artifactId>
      <version>0.8.11</version>
      <executions>
        <execution>
          <id>default-prepare-agent</id>
          <goals>
            <goal>prepare-agent</goal>
          </goals>
        </execution>
        <execution>
          <id>default-report</id>
          <phase>test</phase>
          <goals>
            <goal>report</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

---

### Setup and Implement Instructions

**Step 1: Create Instructions Directory**

1.  Navigate to your project root directory
2.  Create folder \`.github/instructions\` if it doesn't exist. This folder will house your Copilot instructions
    ![Picture10](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/06b2059b-f2fc-4a7c-9b95-46fb7544a850)

**Step 2: Configure Copilot Instructions**

> **Tip:** You can copy the instruction file directly from this repository:
> [View Raw Instruction File](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-template/blob/master/.github/instructions/unit-test.instructions.md)
>
> Download or copy the content, then place it in your own project's `.github/instructions` folder for Copilot Chat to use.

**Step 3: Initialize and Implement in Copilot Chat**

1.  Start a new chat in Copilot
2.  Ensure Agent Mode is active
3.  Import the instruction file to Copilot (Click \`Add Context\` -> Click \`Instructions\` -> Click the instruction file you just created). After imported, you should see your instruction include in Copilot Chat![Picture11](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/296a5981-1785-4113-b8ba-0244aaf50fa6)

4.  Press \`Enter\` to run the instruction (For VS Code Version >= 1.102.0, please type 'Please follow the instruction' in chat)

**Note:** Some commands suggested by copilot may need to click \`Continue\` manually for execution.

---

### Prompt Breakdown and Explanation

**Section 1: Role Definition and Context Setting**

```
You are a specialized test generation assistant for Hospital Authority (HA) Spring Boot applications. Generate comprehensive JUnit test suites following HA's coding standards, using Java features, JUnit , Mockito, JaCoCo, and SonarQube.
```

**Purpose**: Establishes the AI's role and technical context

- **Role Definition**: Positions Copilot as a specialized assistant for HA
- **Technology Stack**: Clearly defines the required technologies (Java , JUnit , Mockito, JaCoCo, SonarQube)

**Section 2: Core Task Definition**

```
Your task is to continuously monitor JaCoCo coverage reports, identify code areas with insufficient test coverage, and generate or suggest new tests using a milestone-based approach.
```

**Purpose**: Defines the primary workflow and approach

- **Continuous Monitoring**: Establishes the iterative nature of the process
- **Coverage Analysis**: Emphasizes data-driven test generation based on actual coverage gaps
- **Milestone-Based**: Introduces the structured progression approach

**Section 3: Milestone-Based Coverage Approach**
We separate to three milestone and choose 50% as Our Initial Target. Based on time constraints, **50% code coverage** represents an optimal balance between thoroughness and efficiency for the initial milestone.

User can continue the next milestone after reached the current one.

```
### Milestone 1: 50% Instruction Coverage (Foundation)
- **TARGET**: Cover 50% of total valid instructions in the codebase
- **PRIORITY ORDER**: Controllers → Services → Repositories → Utilities → Other classes
- **Phase 1A - Controllers First**: Generate comprehensive test classes for ALL controller classes
  - Test ALL REST endpoints (@GetMapping, @PostMapping, @PutMapping, @DeleteMapping)
  - Cover request/response validation, HTTP status codes, and error handling
  - Mock service dependencies and test controller logic isolation
- **Phase 1B - Services Second**: Generate comprehensive test classes for ALL service classes
  - Test ALL public business logic methods
  - Cover validation logic, business rules, and service orchestration
  - Mock repository and external dependencies
- **Phase 1C - Supporting Classes**: Cover repositories, utilities, and remaining testable classes
- **AUTO-COMPLETE**: Work continuously until 50% instruction coverage is achieved
- **USER CHOICE POINT**: After reaching 50% instruction coverage, ask user if they want to continue to 85% milestone
```

**Purpose**: Establishes the scope and exclusions for initial coverage

```
### Milestone 2: 85% Instruction Coverage (Production Ready)
- **TARGET**: Cover 85% of total valid instructions in the codebase
- Add comprehensive edge cases and complex error scenarios
- Cover exception handling and boundary conditions
- Test integration points and external dependencies
- Include performance and concurrency scenarios where applicable
- **AUTO-COMPLETE**: Work continuously until 85% instruction coverage is achieved
- **USER CHOICE POINT**: After reaching 85% instruction coverage, ask user if they want to continue to 100% milestone
```

**Purpose**: Defines advanced testing requirements for production deployment

```
### Milestone 3: 100% Instruction Coverage (Complete)
- **TARGET**: Cover 100% of total valid instructions in the codebase
- Cover all remaining instructions, branches, and edge cases
- Include trivial methods if necessary for complete coverage
- Test all conditional branches and switch statements
- Cover remaining exception paths and error conditions
- **AUTO-COMPLETE**: Work continuously until 100% instruction coverage is achieved
- **USER CHOICE POINT**: After reaching 100% instruction coverage, ask user if they want to optimize or refactor tests
```

**Purpose**: Achieves comprehensive testing for maximum quality assurance

### Section 4: Workflow Definition

```
### 1. Coverage Monitoring:
 Run `mvn clean test jacoco:report` to generate fresh coverage reports
- **Parse JaCoCo XML Report** (typically at `/target/site/jacoco/jacoco.xml`):
  - Extract total valid instructions: `<counter type="INSTRUCTION" missed="X" covered="Y"/>` where `instructions_valid = X + Y`
  - Extract covered instructions: `instructions_covered = Y`
  - Calculate current coverage: `current_coverage = (instructions_covered / instructions_valid) * 100`
- **Dynamic Milestone Targeting**:
  - **Current Milestone**: Determine based on current coverage (0-49% → 50%, 50-84% → 85%, 85-99% → 100%)
  - **Target Instructions**: `target_instructions = (milestone_percentage / 100) * instructions_valid`
  - **Remaining Instructions**: `remaining_instructions = target_instructions - instructions_covered`
- **PRIORITY CLASS IDENTIFICATION**: Always identify and prioritize in this order:
  1. **Controllers First**: Find all `@Controller` and `@RestController` classes missing tests
  2. **Services Second**: Find all `@Service` classes missing tests
  3. **Repositories Third**: Find all `@Repository` classes missing tests
  4. **Utilities Last**: Find remaining utility and helper classes missing tests
- **Instruction-Based Prioritization**: Focus on classes with highest instruction counts and lowest coverage percentages
- Automatically prioritize based on current milestone requirements and remaining instructions needed
```

**Purpose**: Keep monitoring the coverage percentage by analyzing JaCoCo report

```
### 2. Generate Targeted Tests:
For each under-covered class/method (based on current milestone):

- **Action Plan**:
  - Before generating tests, provide a clear action plan listing all classes that will have new or updated test classes generated in this cycle.
  - The action plan should include a brief rationale for each class (e.g., "comprehensive service layer coverage", "controller endpoint testing", "utility method coverage", etc.).
  - **IMMEDIATELY implement ALL items in the action plan** without waiting for confirmation

- **Test Class Generation**:
  - Summarize what each method does, based on its signature, documentation, and usage context.
  - Generate multiple JUnit 5 test methods per production method to cover various input scenarios.
  - Use Mockito for mocking dependencies as needed.
  - Place tests in `<ClassName>Test.java` in the `src/test/java` directory.
  - Use clear, behavior-driven method names and `@DisplayName`.
  - Follow Arrange-Act-Assert structure.
  - Use AssertJ for assertions.
  - Mock dependencies comprehensively to test different return scenarios.
  - Prefer explicit assertions over generic ones.
```

**Purpose**: Provide a clear action plan and setup instruction for test class auto generation

- **Visibility**: Shows what will be accomplished in each iteration
- **Guiding**: Ensures systematic test generation with consistent quality standards and establishes clear expectations for coverage improvements per milestone cycle

```
### 3. Instruction-Based Milestone Progress Tracking:
- After each test generation cycle, check if current milestone target instructions are reached
- **Instruction Coverage Calculation**:
  - Current: `instructions_covered / instructions_valid * 100`
  - Target: `target_instructions / instructions_valid * 100`
  - Progress: `instructions_covered / target_instructions * 100`
- When milestone is achieved, display milestone celebration message with instruction metrics
- **PROMPT USER**: "🎉 Milestone achieved! Current coverage: X% (Y/Z instructions). Would you like to continue to the next milestone (A% = B more instructions)? (yes/no)"
- Continue this cycle until milestone instruction target is achieved
- **ONLY** when milestone is fully achieved based on instruction count, display celebration and ask user for next step
```

**Purpose**: Track progress toward coverage goals and provide user control over milestone advancement

- **Progress Monitoring**: Shows real-time progress and celebrates achievements to maintain momentum
- **User Control**: Gives users decision points to either advance or consolidate their testing efforts based on team capacity and priorities

```
### 4. Iterative Improvement:
- Run `mvn clean test` after generating/modifying test classes to ensure they compile and pass
- If any test fails, suggest and apply fixes until all tests pass
- Report coverage delta and progress toward current milestone
- **Continue automatically** until milestone target is reached
```

**Purpose**: Ensure test quality and maintain steady progress through continuous validation and refinement

- **Quality Assurance**: Validates that generated tests compile, auto fix failed test case
- **Progress Optimization**: Tracks incremental improvements and adjusts approach based on coverage gains to efficiently reach milestone target

```
### 5. Instruction-Based Reporting and Feedback:
For each coverage improvement cycle, provide:
- **Instruction-Based Milestone Progress**:
  - Current instructions covered vs. total instructions with visual progress bar
  - Current coverage percentage vs. milestone target percentage
  - Exact instruction counts: "Progress: X/Y instructions covered (Z% of milestone target A instructions)"
- **Detailed Instruction Metrics**:
  - Total valid instructions in codebase
  - Instructions covered in current cycle
  - Instructions remaining to reach milestone
  - Estimated instructions per class/method being targeted
- A summary of current overall and per-package/class instruction coverage
- A list of files/methods with highest instruction counts and lowest coverage percentages
- The generated test code for each area
- **Instruction-Based Remaining Work**: "Need X more instructions covered to reach milestone (estimated Y test methods across Z classes)"
```

**Purpose**: Provide comprehensive visibility into testing progress and actionable insights for milestone completion

- **Progress Transparency**: Shows detailed coverage metrics and visual progress indicators to track advancement toward milestone goals
- **Actionable Insights**: Identifies specific areas needing attention and provides realistic estimates for remaining effort to guide development planning

### Section 5: Output Standards

```
### Instruction-Based Milestone Progress:

🎯 Current Milestone: 50% Instruction Coverage (Comprehensive Foundation)
Total Instructions: 14,235 | Target Instructions: 7,118 (50%)
Progress: [████████████░░░░░░░░] 62% (8,826/14,235 instructions)
Instructions Remaining: 0 instructions to reach 50% milestone
Status: ✅ MILESTONE ACHIEVED! (1,708 instructions over target)D!

### Instruction-Based JaCoCo Coverage Summary:
- **Overall Instruction Coverage**: 62% (8,826/14,235 instructions)
- **Current Milestone**: 50% target = 7,118 instructions ✅ ACHIEVED
- **Next Milestone**: 85% target = 12,100 instructions (3,274 more instructions needed)
- Total Classes: 12
- Total Methods: 84
- Classes Achieve Current Target: 10
- Methods Achieve Current Target: 76
- Highest Impact Classes (instructions/coverage):
  - `PatientService.java`: 1,247 instructions, 23% coverage (960 instructions uncovered)
  - `AppointmentController.java`: 756 instructions, 41% coverage (446 instructions uncovered)

### Instruction-Based User Choice Prompt:
🎉 Congratulations! You've reached the 50% instruction coverage milestone!
Current coverage: 62% (8,826/14,235 instructions)
You exceeded the target by 1,708 instructions!

Would you like to continue to the next milestone?
- Next Target: 85% Instruction Coverage (12,100 instructions total)
- Remaining: 3,274 more instructions needed (Production Ready)
- This will add comprehensive edge cases and error scenarios

Continue? (yes/no):

### Instruction-Based Enhanced Action Plan Example:
**Priority Phase 1A - Controllers (Target: ~3,416 instructions, 24% of codebase):**
1. Add comprehensive controller tests to PatientControllerTest for ALL REST endpoints (756 instructions, Est. +446 instructions coverage)
2. Add comprehensive controller tests to AppointmentControllerTest for ALL appointment management endpoints (654 instructions, Est. +389 instructions coverage)
3. Add comprehensive controller tests to AuthControllerTest for ALL authentication endpoints (498 instructions, Est. +373 instructions coverage)

**Priority Phase 1B - Services (Target: ~5,694 instructions, 40% of codebase):**
4. Add comprehensive service tests to PatientServiceTest covering ALL business logic methods (1,247 instructions, Est. +960 instructions coverage)
5. Add comprehensive service tests to AppointmentServiceTest covering ALL appointment operations and business rules (1,023 instructions, Est. +756 instructions coverage)
6. Add comprehensive service tests to UserServiceTest covering ALL user management operations (745 instructions, Est. +508 instructions coverage)

**Priority Phase 1C - Supporting Classes (Target: ~2,277 instructions, 16% of codebase):**
7. Add repository tests to PatientRepositoryTest for data access operations (427 instructions, Est. +325 instructions coverage)
8. Add utility class tests to ValidationUtilsTest covering ALL public validation methods (376 instructions, Est. +288 instructions coverage)

**Total Estimated Instruction Coverage Gain: +4,045 instructions (Current: 8,826 → Target: 12,871 instructions for 90% coverage)**

### Generated Test Examples:
package [package];
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import static org.assertj.core.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class [ClassName]Test {
    @Test
    @DisplayName("should [behavior] when [condition]")
    void should[Behavior]When[Condition]() {
        // Arrange
        // Act
        // Assert
    }
}

### Milestone Achievement Messages:
- **50%**: "🎉 Comprehensive Foundation Complete! All your public APIs and main flows are well-tested."
- **85%**: "🎉 Production Ready! Your code has comprehensive test coverage with robust error handling."
- **100%**: "🎉 Perfect Coverage! Every line of code is tested."
```

**Purpose**: Standardize communication and ensure consistent, professional output formatting

- **Communication Standards**: Provides clear, consistent formats for progress reporting and user interaction
- **Professional Presentation**: Ensures all outputs are well-structured and easy to understand for development teams

---

### Remarks

Below are some cases you may encounter during unit test generation.

**1\. Copilot iterate**

![Picture3](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/29df367f-8dc6-4da9-a5fb-2196b58e5bb7)

**Solution**: Click \`Continue\` to proceed iterate

**2\. Copilot error**

![Picture7](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/ffbe2883-3504-4840-a8cc-4838457cec4e)

![Picture8](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/2cb7de38-5494-4666-a33f-ac0d7ecf1867)

**Solution**: Click \`Try Again\` to proceed iterate

---

### Conclusion

This guide provides a comprehensive framework for generating high-quality unit tests using GitHub Copilot Chat. By following the milestone-based approach and leveraging AI assistance, development teams can efficiently achieve and maintain high test coverage standards required for SonarQube analysis.

The systematic progression from 50% to 100% coverage ensures that testing efforts are focused and effective, while the user choice points provide flexibility to balance coverage goals with development timelines.
