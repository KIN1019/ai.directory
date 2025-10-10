---
title: CMS DHPAI Sonarqube Codesmell Resolving Instruction 
description: Complete SonarQube vulnerability fixing to resolve Blocker and Critical code smell issues. Go to [https://hagithub.home/CMS/cms-dhpai-sonarqube-instruction-template-doc] for more details.
tags: [dhpai]
---

## Project Request

**Task**: Complete SonarQube vulnerability fixing to resolve Blocker and Critical code smell issues

**Project Details**:
- Project path: <input your sonarqube project key eg cms-pccms-svc>
- SonarQube server:Please use the sonarqube-mcp
- Git operation: Please use the github mcp, this project is under CMS organization
- Target branch for PR: <input the branch you want to merge into, e.g., main or master>

**Workflow Required**: Please run the following workflow based on SonarQube report. Complete ALL issue types in the order specified:

## INITIAL SETUP

**Git Branch Creation (Do this FIRST before any fixes)**:
- Create new branch: `sonarqube-fix/fix-codesmell_YYYYMMDDHHMM` (use current datetime)
- Switch to this branch for all subsequent work

## PHASE 2: Code Smell Issues (Fix ONLY Blocker and Critical)
**IMPORTANT: Do NOT push yet - this is the final phase before creating single PR**

Please follow the steps below to fix Code Smell issues type:
1. **Direct Issue Processing**
   - **Step 1: Fetch BLOCKER Issues** - Use SonarQube MCP to get BLOCKER Code Smell issues: `mcp_sonarqube_issues` with parameters:
     * `types`: ["CODE_SMELL"]
     * `statuses`: ["OPEN", "REOPENED"]
     * `facets`: ["severities", "rules"]
     * `severities`: ["BLOCKER"]
     * `page_size`: 50 
     * `page`: 1
   - **Step 2: If BLOCKER count > 0, fix them immediately**
     * Process each BLOCKER issue by file
   
   - **Step 3: Fetch CRITICAL Issues Page-by-Page** - Use SonarQube MCP:
     * **Page 1**: `mcp_sonarqube_issues` with same parameters but `severities`: ["CRITICAL"]
     * **Fix Page 1 Issues**: Process all 50 issues from page 1 response immediately
     * **Page 2**: Fetch page 2 and fix those issues
     * **Continue**: Repeat until all CRITICAL pages are processed
     * **CRITICAL**: Fix issues directly from each API response

2. **Analysis & Issue Identification**
   - Process issues directly from SonarQube API responses
   - **IMPORTANT**: Only fix BLOCKER and CRITICAL severity issues
   - **DO NOT FIX**: Major, Minor, or Info severity issues

3. **Code Smell Fixing Priority (ONLY Blocker and Critical) - Direct Processing**
   - **Optimized Workflow**:
     * **Phase 3a: Process BLOCKER Issues (if any)**
       - Fix each blocker issue immediately from API response
     * **Phase 3b: Process CRITICAL Issues Page-by-Page**
       - Fetch page 1, fix all issues in that page, do not fix next page until you have finish all issue in that page
       - Fetch page 2, fix all issues in that page, do not fix next page until you have finish all issue in that page
       - Continue until all CRITICAL pages are processed
   
   - **Issue Fix Process per Page**:
     * Fix all issues in File A, then File B, then File C within the current page
     * **Testing**: Run `mvn compile` after completing each file to ensure no compilation errors
     * **Testing**: Run `mvn test` after completing each page
     * Move to next page only after current page is fully fixed

   - **SKIP**: Do NOT fix Major, Minor, or Info severity issues for Code Smell
   - **Benefit**: No file I/O issues, direct processing, clear progress tracking

4. **Code Standards**
   - Follow existing code style and conventions
   - Ensure changes don't break functionality
   - Maintain original method signatures and functionality

5. **Phase 2 Commit (Individual commit for Code Smell fixes)**
   - Stage all Phase 2 changes: `git add -A`
   - Commit with descriptive message

6. **Final Testing & Validation (Before Git Operations)**
   - Run `mvn test` to ensure all tests pass
   - Run `mvn compile` to ensure no compilation errors
   - **STOP HERE if any tests fail - fix issues before proceeding**

## FINAL PHASE: Pull Request Creation

**IMPORTANT: Only proceed after BOTH Phase 1 and Phase 2 are complete and all tests pass**

1. **Push Branch to Remote**
   - Push branch to remote: `git push origin <branch-name>`
   - Verify branch appears in remote repository

2. **Create Pull Request**
   - Create Pull Request to target branch
   - Use comprehensive PR description template below

3. **Pull Request Description Template**

4. **Final Verification**
   - Verify Pull Request contains comprehensive description
   - Confirm target branch
   - Ensure all commits are included in PR

**Important Notes**:
- Always run tests after significant changes
- Use proper exception handling and resource management
- Follow the existing project's coding standards
- Document all changes in commit messages and PR description