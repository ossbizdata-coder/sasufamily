package com.sasu.family.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.Key;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
public class JwtUtil {

    @Value("${jwt.secret:#{null}}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;

    @Value("${jwt.secret.file:data/.jwt-secret}")
    private String secretFilePath;

    private Key signingKey;

    @PostConstruct
    public void init() {
        if (secret == null || secret.trim().isEmpty()) {
            // Auto-generate and persist secret
            secret = loadOrGenerateSecret();
            System.out.println("✅ JWT secret loaded/generated from: " + secretFilePath);
        }
        signingKey = Keys.hmacShaKeyFor(secret.getBytes());
    }

    private String loadOrGenerateSecret() {
        try {
            Path path = Paths.get(secretFilePath);

            // Create parent directory if needed
            if (path.getParent() != null) {
                Files.createDirectories(path.getParent());
            }

            // Load existing secret
            if (Files.exists(path)) {
                String existing = Files.readString(path).trim();
                if (existing.length() >= 64) {
                    return existing;
                }
            }

            // Generate new secure secret
            SecureRandom random = new SecureRandom();
            byte[] secretBytes = new byte[64]; // 512 bits
            random.nextBytes(secretBytes);
            String newSecret = Base64.getEncoder().encodeToString(secretBytes);

            // Persist for future use
            Files.writeString(path, newSecret);
            System.out.println("🔐 Generated new JWT secret: " + secretFilePath);

            return newSecret;
        } catch (Exception e) {
            System.err.println("⚠️  Failed to load/generate JWT secret file, using fallback");
            // Fallback: generate in-memory (not persistent)
            SecureRandom random = new SecureRandom();
            byte[] secretBytes = new byte[64];
            random.nextBytes(secretBytes);
            return Base64.getEncoder().encodeToString(secretBytes);
        }
    }

    private Key getSigningKey() {
        return signingKey;
    }

    public String generateToken(String username, String role) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", role);
        return createToken(claims, username);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + expiration);

        return Jwts.builder()
                .setClaims(claims)
                .setSubject(subject)
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String extractUsername(String token) {
        return extractAllClaims(token).getSubject();
    }

    public String extractRole(String token) {
        return extractAllClaims(token).get("role", String.class);
    }

    public Date extractExpiration(String token) {
        return extractAllClaims(token).getExpiration();
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public Boolean validateToken(String token, String username) {
        final String tokenUsername = extractUsername(token);
        return (tokenUsername.equals(username) && !isTokenExpired(token));
    }
}

