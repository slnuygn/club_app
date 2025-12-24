# Club App Testing Guide

This repository contains comprehensive testing scripts to ensure the stability, performance, and correctness of the application.

## 1. API & Unit Tests

Located in `test/api_test.dart`, these tests verify the logic of the service layer (`PostService`, `UserService`) by mocking external dependencies like Firebase.

### **Coverage**

- **PostService**:
  - Fetching single posts and clubs.
  - Fetching all posts with filtering.
  - Toggling likes on posts.
- **UserService**:
  - Creating new user documents.
  - Updating existing user profiles.

### **How to Run**

```bash
flutter test test/api_test.dart
```

---

## 2. Stress & Performance Tests

Located in `test/stress_test.dart`, these tests benchmark the performance of core data models and logic under heavy load.

### **Scenarios**

1.  **JSON Parsing**: Parsing 10,000 raw JSON maps into `Post` objects. (Target: < 300ms)
2.  **List Processing**: Filtering and sorting 20,000 `Post` objects. (Target: < 150ms)
3.  **Widget Instantiation**: Creating 50,000 `PostCard` widget objects. (Target: < 200ms)

### **How to Run**

```bash
flutter test test/stress_test.dart
```

### **Interpreting the Stress Report**

The script outputs a formatted report:

- **Ideal Score**: The target performance threshold.
- **App Score**: The actual time taken.
- **Performance Index**: > 100% means the app is faster than the baseline.
- **Status**: `PASS` or `WARN`.

---

## 3. Running All Tests

To run all tests in the repository:

```bash
flutter test
```
