package com.example.calculator.dto;

/**
 * The exact JSON shape the spec requires:
 * { "operation": "add", "a": 2, "b": 3, "result": 5 }
 */
public record CalculationResponse(String operation, double a, double b, double result) {}
