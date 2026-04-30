# Copilot SonarQube Report Resolving Guide

## Verification Required

All code generated should be thoroughly reviewed and tested before implementation. The AI may not account for specific project requirements or environments.

## Overview

This document provides comprehensive guidance for integrating SonarQube MCP and GitHub MCP to establish AI-driven code quality management and automated pull request workflows.

**Key Benefits**

- **Automated Code Remediation**: AI agents analyze failed Quality Gate conditions and generate targeted code fixes, significantly reducing manual effort while improving consistency across the codebase.
- **Continuous Quality Enforcement**: Quality Gates function as real-time checkpoints, ensuring that only clean, secure, and maintainable code is merged into production environments.
- **Enhanced Developer Productivity**: By automating repetitive tasks such as code review, issue triage, and pull request submission, development teams can deliver software faster with fewer errors.

---

## Prerequisites

### IDE and Copilot Proxy Setup

- [IDE Setup - Visual Studio Code](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/Source_Control/GitHub/GitHub_Copilot/Copilot_Setup/IDE_Setup_-_Visual_Studio_Code.html)
- [IDE Setup - IntelliJ IDEA](http://cnaf.home/Cloud%20Native%20Application%20Framework/Platform%20Pattern/Source_Control/GitHub/GitHub_Copilot/Copilot_Setup/IDE_Setup_-_IntelliJ_IDEA.html)

### Visual Studio Code

- Version 1.102 or above is required
- Latest version is recommended for optimal performance

### GitHub Copilot Chat

- Ensure Agent Mode is enabled for code editing
- If unavailable, enable by setting \`chat.agent.enabled\` in VS Code settings (Ctrl + ,)![Picture4](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/82e61be0-6d77-4003-874c-ab171ea490cf)
- Enable auto-approval `chat.tools.autoApprove` in VS Code settings (Ctrl + ,)![Picture6](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/9f64a154-6f3f-4b4b-84fb-23a7751626a7)
- [**For VS Code version v1.104.0**] Enable Global Auto Approve `global.auto.approve` in VS Code settings (Ctrl + ,)![Picture9](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/3945e828-13e7-4f76-bb52-90b7516c8e41)
- Set `Max Requests` to 999 in VS Code settings (Ctrl + ,)![Picture5](https://hagithub.home/CMS/cms-dhpai-unit-test-generation-doc/assets/2991/5229a282-4435-4db7-8f99-e8a52620209e)
- Start a new Copilot Chat session before running unit test generation

### LLM Model Suggestion

- **Recommended**: Use **Claude Sonnet 4.5**
- For **GPT-4.1**, please reference to [cms-dhpai-copilot-booster-doc](https://hagithub.home/CMS/cms-dhpai-copilot-booster-doc)

### NPM Installation

- SonarQube MCP requires NPM installation. Please download and install NPM from https://nodejs.org/en/download/

## Setup SonarQube MCP Server Instructions

### Install SonarQube MCP SERVER

- Download the ha-sonarqube-mcp-server from HA Artifactory:
  [ha-sonarqube-mcp-server.zip](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/releases/download/1.0.0.mcp.soruce/ha-sonarqube-mcp-server.zip)
- Unzip the ha-sonarqube-mcp-server

- cd to the folder and Install the ha-sonarqube-mcp-server on your instance:
  ```
  npm ci
  ```

### Generate the SonarQube API Token

1. Log in to the SonarQube Server
2. Navigate to My Account settings![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/469d7cce-e6e5-487c-a3f0-1262759e538e)

3. Select the Security tab and generate a User token![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/6d507646-be7a-497b-b914-4ff91e34eff0)

4. Copy the generated token for use in the VS Code SonarQube MCP setup![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/0f053fa1-2705-4bb5-9226-48b4bdbb0f90)

### Setup SonarQube MCP in VS Code

1. For user with vscode Version < 1.102.X. Open the VS Code MCP settings.json file![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/d105f9d7-34fb-4051-8810-8671fc866811)<br>
   For user with vscode Version >= 1.102.X. Presse ctrl+Shift+P to open MCP User Config![Screenshot 2025-10-02 121820](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/4308022c-2592-40b5-abcd-4a1b715c7683)

2. Insert the following configuration to establish the SonarQube MCP server connection

```
"mcp": {
    "inputs": [],
    "servers": {
        "sonarqube": {
            "type": "stdio",
            "command": "node",
            "args": ["<path_to_your_unzipped_folder>\\ha-sonarqube-mcp-server\\package\\dist\\index.js"],
            "env": {
                "SONARQUBE_URL": "https://hatool-sonarqube.home",
                "SONARQUBE_TOKEN": "<token>"
            }
        },
        // other mcp servers you have configured
    }
}
```

3. Upon successful configuration, you should observe the SonarQube server starting and displaying the number of available tools![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/ce00d8c2-be6d-4521-b1fc-18903afa0bcb)

## Setup GitHub MCP Server Instructions

### Install GitHub MCP SERVER (Windows Users)

- Visit the official release page: https://github.com/github/github-mcp-server/releases
- Download the file: github-mcp-server_Windows_x86_64.zip
- Extract the downloaded .zip archive to your preferred installation directory
  - Ensure the folder contain github-mcp-server.exe is accessible and does not require administrative permissions for execution
- Add the GitHub MCP server path to your system's environment variables:
  - Open System Properties → Environment Variables
  - Under System Variables, locate and select Path, then click Edit
  - Add the full path of the GitHub MCP server executable (e.g., C:\tools\github-mcp-server\)
- Click OK to save changes and close all dialogs
  ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/cf3bc5dc-936e-4fea-9cfb-c74081d29d49)

- Once the GitHub MCP server has been successfully added to your system's environment path:
  - Launch Windows PowerShell
  - Execute the command `github-mcp-server --version`
  - If configured correctly, PowerShell should recognize the command and return the current version of the GitHub MCP server

### Generate the GitHub PAT Token

1. Log in to HA GitHub
2. Click your profile to access Settings and Developer settings
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/5612ae9d-b426-425e-932a-d7ccf3f50d2c)

3. Select Tokens (classic) to Generate new token (classic)![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/c617ab23-f81e-4d95-b1b2-0cfed57e2fdf)

4. Select the corresponding scopes to create the personal access token
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/9c6cb158-ffe4-4c12-9534-cf860148ea6f)

5. Copy the generated token for use in the VS Code GitHub MCP setup
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/fdd5d6a4-e9ab-4bad-8a47-09a205353188)

### Setup GitHub MCP in VS Code

1. For user with vscode Version < 1.102.X. Open the VS Code MCP settings.json file![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/d105f9d7-34fb-4051-8810-8671fc866811)<br>
   For user with vscode Version >= 1.102.X. Presse ctrl+Shift+P to open MCP User Config![Screenshot 2025-10-02 121820](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/4308022c-2592-40b5-abcd-4a1b715c7683)

2. Insert the following configuration to establish the GitHub MCP server connection

```
"mcp": {
    "inputs": [],
    "servers": {
        "ha-github": {
            "type": "stdio",
            "command": "github-mcp-server",
            "args": [
                "stdio"
            ],
            "env": {
                "GITHUB_PERSONAL_ACCESS_TOKEN": "<Your GitHub PAT Token>",
                "GITHUB_HOST": "https://hagithub.home"
            }
        },
        // other mcp servers you have configured
    }
}
```

3. Upon successful configuration, you should observe the GitHub MCP server starting and displaying the number of available tools
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/d3981cfc-9d52-4845-af26-1e64db31cbe5)

## Setup and Implementation Instructions

### Step 1: Create Instructions Directory and enable copilot timer tool

#### Create Instructions Directory

1. Navigate to your project root directory
2. Create the folder `.github/instructions` if it does not exist. This folder will house your Copilot instructions

#### Enable Copilot timer tool

https://hagithub.home/CMS/cms-dhpai-react-generation-doc/assets/2991/93b52d80-dce7-4836-be53-f973b670969c

1. Download [copilot-timer](https://hagithub.home/CMS/cms-dhpai-react-generation-doc/raw/copilot-timer/copilot-timer-0.0.3.vsix)
2. Drag and drop copilot-timer to VS Code Extension
3. After installed, click "Enable auto Start"

### Step 2: Determine Issue Types to Fix

Before choosing an instruction file, identify which types of SonarQube issues your project has:

1. **Access your SonarQube project dashboard**
2. **Review the Issues overview** to see the breakdown by type:
   - **Bugs** - Logic errors that could cause runtime failures
   - **Vulnerabilities** - Security-related issues that could expose the application to attacks
   - **Code Smells** - Maintainability issues that make code harder to understand or change
     ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/bf0ed47c-cb1a-4fd6-bdad-f8d140ccd192)

3. **Choose the appropriate instruction file(s)**:
   - Use **Bug instruction** if you have Bug issues to resolve
   - Use **Vulnerability instruction** if you have Vulnerability/Security issues to resolve
   - Use **Code Smell instruction** if you have Code Smell/Maintainability issues to resolve

> **Tip:** You can run multiple instruction sessions sequentially to address different issue types. For example, fix all Vulnerabilities first (highest security priority), then Bugs, then Code Smells.

### Step 3: Configure Copilot Instructions

> **Tip:** You can copy the instruction files directly from this repository:
> [View Raw Instruction Files](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/blob/master/.github/instructions/)
>
> **Available Instruction Files:**
>
> - **`sonarqube-bug-resolving.instructions.md`** - For fixing BUG issues (all severities)
> - **`sonarqube-vulnerability-resolving.instructions.md`** - For fixing VULNERABILITY issues (all severities)
> - **`sonarqube-codesmell-resolving.instructions.md`** - For fixing CODE_SMELL issues (BLOCKER and CRITICAL only)
>
> Download or copy the content of the appropriate instruction file, then place it in your own project's `.github/instructions` folder for Copilot Chat to use. Please also update the SonarQube Project name and PR branch based on your needs.
> ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/bed02240-9730-4653-9785-ded4fcbd8798)

### Step 4: Choose and Initialize Instruction in Copilot Chat

**Choose the appropriate instruction file based on your SonarQube issue type:**

#### For Bug Issues:

1. Start a new Chat session in Copilot
2. Ensure Agent Mode is active
3. Click Configure Tools to verify that the required MCPs are enabled
4. Import the **bug resolving** instruction file to Copilot (Click `Add Context` → Click `Instructions` → Select `sonarqube-bug-resolving.instructions.md`). After import, you should see your instruction included in Copilot Chat
5. Input `Please run the instruction` then press `Enter` to execute the prompt
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/47d6ed78-5fa5-4763-b2f1-c222b6105ce8)

#### For Vulnerability Issues:

1. Start a new Chat session in Copilot
2. Ensure Agent Mode is active
3. Click Configure Tools to verify that the required MCPs are enabled
4. Import the **vulnerability resolving** instruction file to Copilot (Click `Add Context` → Click `Instructions` → Select `sonarqube-vulnerability-resolving.instructions.md`). After import, you should see your instruction included in Copilot Chat
5. Input `Please run the instruction` then press `Enter` to execute the prompt
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/ef4aea06-200a-4058-9766-15bd84f91d7c)

#### For Code Smell Issues:

1. Start a new Chat session in Copilot
2. Ensure Agent Mode is active
3. Click Configure Tools to verify that the required MCPs are enabled
4. Import the **code smell resolving** instruction file to Copilot (Click `Add Context` → Click `Instructions` → Select `sonarqube-codesmell-resolving.instructions.md`). After import, you should see your instruction included in Copilot Chat
5. Input `Please run the instruction` then press `Enter` to execute the prompt
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/56ab2d43-60c6-4eac-a683-f42b64608ae7)

**Note**: Some commands suggested by Copilot may require manual confirmation by clicking `Continue` for execution.

## Prompt Breakdown and Explanation(Code Smell)

### Section 1: Define Task Mission

```
## Project Request

**Task**: Complete SonarQube code smell fixing to resolve Blocker and Critical code smell issues

**Project Details**:
- Project path: <input your sonarqube project key eg cms-pccms-svc>
- SonarQube server: Please use the sonarqube-mcp
- Git operation: Please use the github mcp, this project is under CMS organization
- Target branch for PR: <input the branch you want to merge into, e.g., main or master>
```

**Purpose**: Establishes the AI's objective and working context

- **Task Objective**: Focus specifically on Code Smell issues with BLOCKER and CRITICAL severities only
- **Service Scope**: Focus exclusively on the specified SonarQube project key
- **SonarQube Source**: Obtain standardized scan results via sonarqube-mcp server
- **GitHub Flow**: Submit final code to the specified target branch via GitHub MCP

### Section 2: Define Git Workflow and Issue Processing Strategy

```
## INITIAL SETUP

**Git Branch Creation (Do this FIRST before any fixes)**:
- Create new branch: `sonarqube-fix/fix-codesmell_YYYYMMDDHHMM` (use current datetime)
- Switch to this branch for all subsequent work

## PHASE 2: Code Smell Issues (Fix ONLY Blocker and Critical)

1. **Direct Issue Processing**
   - **Step 1: Fetch BLOCKER Issues** - Use SonarQube MCP to get BLOCKER Code Smell issues
   - **Step 2: If BLOCKER count > 0, fix them immediately**
   - **Step 3: Fetch CRITICAL Issues Page-by-Page** - Process systematically
```

**Purpose**: Guides the AI through systematic issue discovery and prioritized resolution

- **Branch Strategy**: Use timestamped branches for traceability and organization
- **Severity Focus**: Restrict processing to BLOCKER and CRITICAL severities only
- **Page-by-Page Processing**: Ensure comprehensive coverage without overwhelming the system
- **Immediate Processing**: Fix issues directly from API responses for efficiency

### Section 3: Define Processing Methodology and Restrictions

```
2. **Analysis & Issue Identification**
   - Process issues directly from SonarQube API responses
   - **IMPORTANT**: Only fix BLOCKER and CRITICAL severity issues
   - **DO NOT FIX**: Major, Minor, or Info severity issues

3. **Code Smell Fixing Priority (ONLY Blocker and Critical) - Direct Processing**
   - **Optimized Workflow**:
     * **Phase 3a: Process BLOCKER Issues (if any)**
     * **Phase 3b: Process CRITICAL Issues Page-by-Page**
```

**Purpose**: Enforces strict processing rules and workflow optimization

- **Severity Restrictions**: Clear boundaries on what should and should not be fixed
- **Direct Processing**: Eliminate file I/O bottlenecks by working directly with API responses
- **Systematic Approach**: Process issues by severity first, then by page within each severity

### Section 4: Define Testing and Quality Assurance

```
   - **Issue Fix Process per Page**:
     * Fix all issues in File A, then File B, then File C within the current page
     * **Testing**: Run `mvn compile` after completing each file to ensure no compilation errors
     * **Testing**: Run `mvn test` after completing each page
     * Move to next page only after current page is fully fixed

6. **Final Testing & Validation (Before Git Operations)**
   - Run `mvn test` to ensure all tests pass
   - Run `mvn compile` to ensure no compilation errors
   - **STOP HERE if any tests fail - fix issues before proceeding**
```

**Purpose**: Ensures code stability and prevents regressions through systematic validation

- **File-by-File Validation**: Catch compilation issues immediately after each file modification
- **Page-by-Page Testing**: Ensure functional correctness before proceeding to next batch
- **Final Gate**: Mandatory testing checkpoint before any Git operations

### Section 5: Define Git Operations and Pull Request Workflow

```
## FINAL PHASE: Pull Request Creation

1. **Push Branch to Remote**
   - Push branch to remote: `git push origin <branch-name>`
   - Verify branch appears in remote repository

2. **Create Pull Request**
   - Create Pull Request to target branch
   - Use comprehensive PR description template below

4. **Final Verification**
   - Verify Pull Request contains comprehensive description
   - Confirm target branch
   - Ensure all commits are included in PR
```

**Purpose**: Establishes a structured and auditable workflow for code delivery

- **Branch Verification**: Ensure successful remote push before PR creation
- **Comprehensive Documentation**: Require detailed PR descriptions for reviewability
- **Quality Checklist**: Final verification steps to ensure completeness

### Section 6: Define Code Standards and Mandatory Practices

```
4. **Code Standards**
   - Follow existing code style and conventions
   - Ensure changes don't break functionality
   - Maintain original method signatures and functionality

**Important Notes**:
- Always run tests after significant changes
- Use proper exception handling and resource management
- Follow the existing project's coding standards
- Document all changes in commit messages and PR description
```

**Purpose**: Communicates mandatory operating rules and quality standards

- **Style Consistency**: Maintain existing codebase formatting and conventions
- **Functional Integrity**: Preserve original behavior while improving code quality
- **Documentation Requirements**: Ensure all changes are properly documented for future maintenance

## Remarks

Below are some scenarios you may encounter during unit test generation:

1. **Copilot Iteration**
   ![image](https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc/assets/2380/c370c0d9-91d2-4ed9-aa7e-de3ea14a4611)

- **Solution**: Click `Continue` to proceed with iteration

## Conclusion

This guide presents a robust and scalable methodology for enhancing SonarQube code quality ratings through the strategic implementation of GitHub Copilot Chat with SonarQube MCP.

By adhering to the outlined framework, development teams can achieve meaningful improvements in code reliability, security, and maintainability while preserving the governance and precision required for enterprise-grade software delivery. The workflow emphasizes structured issue triage, consistent Git operations, and thorough pull request documentation, fostering clarity, accountability, and long-term codebase health.

This disciplined approach not only minimizes technical debt but also accelerates delivery velocity and enables teams to adapt seamlessly to dynamic project demands. For continued support or deeper integration guidance, refer to the MCP or SonarQube documentation, or consult platform engineering and support channels.
