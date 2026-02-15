package com.sasu.family.service;

import com.sasu.family.model.Liability;
import com.sasu.family.repository.LiabilityRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class LiabilityService {

    private final LiabilityRepository liabilityRepository;

    public List<Liability> getAllLiabilities() {
        return liabilityRepository.findByActiveTrue();
    }

    public Liability getLiabilityById(Long id) {
        return liabilityRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Liability not found"));
    }

    public Liability createLiability(Liability liability) {
        liability.setActive(true);
        return liabilityRepository.save(liability);
    }

    public Liability updateLiability(Long id, Liability liabilityDetails) {
        Liability liability = getLiabilityById(id);

        liability.setName(liabilityDetails.getName());
        liability.setType(liabilityDetails.getType());
        liability.setOriginalAmount(liabilityDetails.getOriginalAmount());
        liability.setRemainingAmount(liabilityDetails.getRemainingAmount());
        liability.setMonthlyPayment(liabilityDetails.getMonthlyPayment());
        liability.setInterestRate(liabilityDetails.getInterestRate());
        liability.setStartDate(liabilityDetails.getStartDate());
        liability.setEndDate(liabilityDetails.getEndDate());
        liability.setDescription(liabilityDetails.getDescription());
        liability.setAutoCalculate(liabilityDetails.getAutoCalculate() != null ? liabilityDetails.getAutoCalculate() : false);

        return liabilityRepository.save(liability);
    }

    public void deleteLiability(Long id) {
        Liability liability = getLiabilityById(id);
        liability.setActive(false);
        liabilityRepository.save(liability);
    }
}

