package com.sasu.family.controller;

import com.sasu.family.dto.FutureProjectionDTO;
import com.sasu.family.service.FutureProjectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Future Projection Controller
 *
 * Shows year-wise future benefits.
 * Available to all authenticated users.
 */
@RestController
@RequestMapping("/api/future")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class FutureProjectionController {

    private final FutureProjectionService futureProjectionService;

    @GetMapping("/projections")
    @PreAuthorize("hasAnyRole('ADMIN', 'FAMILY')")
    public ResponseEntity<FutureProjectionDTO> getFutureProjections(
            @RequestParam(defaultValue = "35") int currentAge) {
        return ResponseEntity.ok(futureProjectionService.getFutureProjections(currentAge));
    }
}

