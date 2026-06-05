```markdown
# flutterOnecard Development Patterns

> Auto-generated skill from repository analysis

## Overview
This skill teaches the core development conventions and workflows used in the `flutterOnecard` TypeScript codebase. You'll learn about file naming, import/export styles, commit patterns, and how to update CI/CD workflows—especially for iOS builds. This guide is ideal for contributors aiming to maintain consistency and efficiency in the project.

## Coding Conventions

### File Naming
- **Style:** snake_case
- **Example:**  
  ```plaintext
  user_profile.ts
  payment_service.ts
  ```

### Import Style
- **Relative Imports:**  
  Use relative paths to import modules within the project.
  ```typescript
  import { getUser } from './user_service';
  ```

### Export Style
- **Named Exports:**  
  Export functions, classes, or constants using named exports.
  ```typescript
  export function getUser(id: string) { ... }
  export const MAX_LIMIT = 100;
  ```

### Commit Patterns
- **Type:** Freeform (no enforced prefix or structure)
- **Average Length:** ~20 characters
- **Example:**  
  ```
  update payment logic
  fix ios build script
  ```

## Workflows

### Update iOS Build Workflow
**Trigger:** When someone wants to change the iOS build process or settings in GitHub Actions.  
**Command:** `/update-ios-build-workflow`

1. Edit the `.github/workflows/ios_build.yml` file to adjust build steps or environment variables.
2. Commit the changes with a message referencing `ios_build.yml`.
   ```bash
   git add .github/workflows/ios_build.yml
   git commit -m "update ios_build.yml for new build step"
   git push
   ```
3. Open a pull request if required by project policy.

## Testing Patterns

- **Framework:** Unknown (not detected)
- **Test File Pattern:** Files ending with `.test.*`
- **Example:**
  ```typescript
  // user_service.test.ts
  import { getUser } from './user_service';

  test('should fetch user by ID', () => {
    expect(getUser('123')).toEqual({ id: '123', name: 'Alice' });
  });
  ```

## Commands

| Command                     | Purpose                                              |
|-----------------------------|------------------------------------------------------|
| /update-ios-build-workflow  | Update the iOS build workflow configuration for CI/CD |
```
