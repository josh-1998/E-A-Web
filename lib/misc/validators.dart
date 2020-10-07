bool passwordValidator() {
  return true;
}

/// checks that the string is not empty, and it is not over a defined length
bool stringNotEmptyValidator(String string, {int maxLength, int minLength}) {
  if (string == '' || string == null) return false;
  if (maxLength != null) {
    if (string.length > maxLength) return false;
  }
  if (minLength != null) {
    if (string.length < minLength) return false;
  }
  return true;
}
