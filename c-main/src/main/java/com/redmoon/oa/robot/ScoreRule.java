package com.redmoon.oa.robot;

public class ScoreRule {
    String code;

    public ScoreRule() {
    }

    public ScoreRule(String code, int value) {
        this.code = code;
        this.value = value;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }

    String name;
    int value = 0;
}
