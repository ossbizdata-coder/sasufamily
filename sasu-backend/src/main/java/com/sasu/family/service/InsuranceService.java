package com.sasu.family.service;

import com.sasu.family.model.Insurance;
import com.sasu.family.repository.InsuranceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class InsuranceService {

    private final InsuranceRepository insuranceRepository;

    public List<Insurance> getAllInsurance() {
        return insuranceRepository.findByActiveTrue();
    }

    public Insurance getInsuranceById(Long id) {
        return insuranceRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Insurance not found"));
    }

    public Insurance createInsurance(Insurance insurance) {
        insurance.setActive(true);
        return insuranceRepository.save(insurance);
    }

    public Insurance updateInsurance(Long id, Insurance insuranceDetails) {
        Insurance insurance = getInsuranceById(id);

        insurance.setPolicyName(insuranceDetails.getPolicyName());
        insurance.setType(insuranceDetails.getType());
        insurance.setProvider(insuranceDetails.getProvider());
        insurance.setCoverageAmount(insuranceDetails.getCoverageAmount());
        insurance.setPremiumAmount(insuranceDetails.getPremiumAmount());
        insurance.setPremiumFrequency(insuranceDetails.getPremiumFrequency());
        insurance.setStartDate(insuranceDetails.getStartDate());
        insurance.setMaturityYear(insuranceDetails.getMaturityYear());
        insurance.setMaturityBenefit(insuranceDetails.getMaturityBenefit());
        insurance.setBeneficiary(insuranceDetails.getBeneficiary());
        insurance.setDescription(insuranceDetails.getDescription());

        return insuranceRepository.save(insurance);
    }

    public void deleteInsurance(Long id) {
        Insurance insurance = getInsuranceById(id);
        insurance.setActive(false);
        insuranceRepository.save(insurance);
    }
}

