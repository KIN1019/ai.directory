# Generating Unit Tests for SonarQube Analysis in Visual Studio Code with Copilot 

This guide explains how to automatically generate unit tests for your Spring Boot project using GitHub Copilot Chat (Agent Mode) in Visual Studio Code, optimized for SonarQube analysis.

## Preconditions

- **Visual Studio Code**: Version **1.99** or above.
- **Copilot Chat Agent Mode**:  
  - Ensure you are using **Agent Mode** for code editing.
  - *Optional*: If Agent Mode is unavailable, enable it by setting `chat.agent.enabled` in your VS Code settings.
- **Start a New Chat**: Begin a new Copilot Chat session before running the unit test generation prompt.
- **AI Model**: For better results, use **GPT-4.1** or above as the AI model in Copilot Chat.
- **JaCoCo Plugin**:  
  - Open your `pom.xml`.
  - Ensure the **JaCoCo Maven plugin** is present.  
    If not, please add the JaCoCo Plugin.

## Unit Test Generation Prompt

Copy and paste the following prompt into Copilot Chat (Agent Mode) and run:

```
For this Spring Boot project, scan all source files under src/main/java, including all subpackages (such as controller, service, utils, dto, etc.), but exclude any files in a config/ folder or package. 
For every public class and public method found (except those in config): 
1. Generate comprehensive unit tests using JUnit 5 and Mockito (or the project’s standard test framework). 
2. Each unit test must be: 
   - Correct: Test the intended functionality and expected outcomes. 
   - Isolated: Test only the target unit, mocking or stubbing all dependencies. 
   - Repeatable: Always produce the same result when run multiple times. 
   - Clear: Use descriptive method names and clear Arrange-Act-Assert structure. 
   - Comprehensive: Cover normal cases, edge cases, and error/exception scenarios. 
3. If a corresponding test file does not exist in src/test/java, create it in the correct package, following the naming convention ClassNameTest.java. 
4. Ensure the generated tests follow project naming and structure conventions. 
5. Automatically run all unit tests (e.g., using mvn test). 
6. After running the tests, parse the generated test report files (e.g., surefire-reports/*.xml and *.txt) and provide a summary including: 
   - Total number of tests run 
   - Number of tests passed, failed, and skipped 
   - Names of any failed tests and their error messages 
   - Code coverage percentage (from the JaCoCo report) 
   - Any uncovered code or areas needing more tests 
7. If any test fails, suggest and apply fixes until all tests pass. 
8. Summarize the test results and code coverage in a clear, human-readable report. 
This prompt should work for any Spring Boot project and generate or update unit tests for all relevant classes (excluding config), not just the currently open file. All steps should be performed automatically after pasting this prompt.
```

## Benchmark: Project Unit Test Coverage

> **SonarQube Pass Criteria:** Coverage percentage must be **≥ 80%**.

### Project: cms-pccms-storage-pri-svc

> **Note:** The following folders are excluded from SonarQube coverage analysis, as specified in `sonar-project.properties`:
> - `src/test/**`
> - `**/util/**`
> - `**/config/**`
> 

| Folder      | Classes (count) | Public Functions (count) |
|-------------|-----------------|--------------------------|
| controller  | 1               | 4                        |
| service     | 2               | 13                       |
| utils       | 4               | 48                       |
| dto         | 10              | 6 (getters/setters)      |

- **SonarQube average coverage:** ~61%
- **Manually implemented coverage:** ~19%
- **Manually implemented functions:** switch case, try catch, etc

### Project: cms-pccms-scheduler-svc

> **Note:** The following folders are excluded from SonarQube coverage analysis, as specified in `sonar-project.properties`:
> - `src/test/**`
> - `**/config/**`
> 

| Folder      | Classes (count)                | Public Functions (count)         |
|-------------|-------------------------------|----------------------------------|
| service     | 4                             | 8                                |
| client      | 4 (interfaces/classes)        | 12                               |
| entity      | 3                             | 11 (getters/setters/builders)    |
| factory     | 1                             | 1                                |


- **SonarQube average coverage:** ~70%
- **Manually implemented coverage:** ~10%
