package org.example.pojo.batch;

public enum BatchRunMode {
    AUTO,
    MANUAL;

    public static BatchRunMode from(String value) {
        if (value == null) {
            return AUTO;
        }
        String v = value.trim().toUpperCase();
        if ("MANUAL".equals(v)) {
            return MANUAL;
        }
        return AUTO;
    }
}
