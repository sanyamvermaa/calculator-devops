package com.example.calculator.dto;

import java.time.Instant;

/**
 * Structured error body for 400s and other failures.
 * Example:
 *   { "timestamp": "2026-10-28T10:00:00Z",
 *     "status": 400,
 *     "error": "Bad Request",
 *     "message": "Cannot divide by zero",
 *     "path": "/api/v1/divide" }
 */
public record ApiError(Instant timestamp,
                       int status,
                       String error,
                       String message,
                       String path) {}
