package com.utcn.manga_review.service.validations;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class UserValidator {
    private static final String USERNAME_VALIDATION_REGEX = "^[a-zA-Z0-9_!#$%&'*+/=?`{|}~^.-]+";
    private static final int MIN_PASSWORD_LENGTH = 7;
    private boolean containsSpecialCharacter(String s) {
        if (s == null || s.trim().isEmpty()) {
            return false;
        }

        Pattern p = Pattern.compile("[^A-Za-z0-9]");
        Matcher m = p.matcher(s);

        return m.find();
    }

    private boolean containsDigit(String s) {
        if (s != null && !s.isEmpty()) {
            for (char c : s.toCharArray()) {
                if (Character.isDigit(c)) {
                    return true;
                }
            }
        }

        return false;
    }

    public boolean validateUsername(String username) {
        return Pattern.compile(USERNAME_VALIDATION_REGEX).matcher(username).matches();
    }

    public String validatePassword(String password) {
        if (password.length() < MIN_PASSWORD_LENGTH) {
            return "Password too short!";
        }

        if (!containsSpecialCharacter(password)) {
            return "Password must contain at least one special character!";
        }

        if (!containsDigit(password)) {
            return "Password must contain at least one digit!";
        }

        return "Password OK";
    }
}
