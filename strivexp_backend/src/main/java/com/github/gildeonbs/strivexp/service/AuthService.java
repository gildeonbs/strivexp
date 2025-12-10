package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.config.security.JwtService;
import com.github.gildeonbs.strivexp.dto.AuthPayloads.*;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    public AuthenticationResponse register(RegisterRequest request) {
        var user = User.builder()
                .displayName(request.firstName() + " " + request.lastName())
                .lastName(request.lastName())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .birthdayDate(request.birthday())
                .isActive(true)
                .locale("en_US") // Default, can be passed in request later
                .timezone("UTC")
                .build();
        
        userRepository.save(user);

        // Generate Token
        // We load the UserDetails again to ensure we match the format Spring expects
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        
        // Add UserID to token claims so Flutter can access it easily
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("userId", user.getId());
        
        var jwtToken = jwtService.generateToken(extraClaims, userDetails);
        return new AuthenticationResponse(jwtToken, null);
    }

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.email(),
                        request.password()
                )
        );
        
        var user = userRepository.findByEmail(request.email())
                .orElseThrow();
                
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("userId", user.getId());

        var jwtToken = jwtService.generateToken(extraClaims, userDetails);
        return new AuthenticationResponse(jwtToken, null);
    }
}
