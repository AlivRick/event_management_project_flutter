String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Email is required";
  }
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return "Invalid email format";
  }
  return null;
}

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return "Password is required";
  }
  if (value.length < 6) {
    return "Password must be at least 6 characters";
  }
  return null;
}
