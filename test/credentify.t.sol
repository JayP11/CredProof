// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Credentify.sol";

contract credentify is Test {
    DecentralizedCredentialSystem public credentialSystem;

    address public deployer = address(0xA1);
    address public university = address(0xB1);
    address public student = address(0xC1);
    address public hacker = address(0xD1);

    function setUp() public {
        vm.prank(deployer);
        credentialSystem = new DecentralizedCredentialSystem();

        // Give admin role to university
        vm.prank(deployer);
        credentialSystem.addUniversity(university);
    }

    function testOnlyUniversityCanIssueCertificate() public {
        vm.startPrank(university);

        credentialSystem.issueCertificate(
            student,
            "Aditya Ingole",
            "Blockchain",
            "B.Tech",
            "ipfs://Qm123..."
        );

        vm.stopPrank();

        // Ensure hacker cannot issue
        vm.expectRevert();
        vm.prank(hacker);
        credentialSystem.issueCertificate(
            student,
            "Aditya",
            "Hacking 101",
            "Fake Degree",
            "ipfs://fake"
        );
    }

    function testCertificateDataIsStoredCorrectly() public {
        vm.prank(university);
        credentialSystem.issueCertificate(
            student,
            "Aditya Ingole",
            "Blockchain",
            "B.Tech",
            "ipfs://Qm123..."
        );

        uint256[] memory certIds = credentialSystem.getStudentCertificateIds(student);
        assertEq(certIds.length, 1);

        uint256 certId = certIds[0];
        (
            uint256 id,
            string memory name,
            address studentAddr,
            string memory course,
            string memory degree,
            uint256 issueDate,
            string memory ipfsHash,
            bytes32 dataHash
        ) = credentialSystem.certificates(certId);

        assertEq(id, 1);
        assertEq(name, "Aditya Ingole");
        assertEq(studentAddr, student);
        assertEq(course, "Blockchain");
        assertEq(degree, "B.Tech");
        assertEq(ipfsHash, "ipfs://Qm123...");
        assertTrue(issueDate > 0);

        // Recalculate and verify hash matches
        bytes32 expectedHash = keccak256(
            abi.encodePacked(name, studentAddr, course, degree, ipfsHash)
        );

        assertEq(dataHash, expectedHash);
    }

    function testVerifyCertificateSuccess() public {
        vm.prank(university);
        credentialSystem.issueCertificate(
            student,
            "Aditya Ingole",
            "Blockchain",
            "B.Tech",
            "ipfs://Qm123..."
        );

        uint256[] memory certIds = credentialSystem.getStudentCertificateIds(student);
        uint256 certId = certIds[0];

        bool valid = credentialSystem.verifyCertificate(
            certId,
            "Aditya Ingole",
            student,
            "Blockchain",
            "B.Tech",
            "ipfs://Qm123..."
        );

        assertTrue(valid);
    }

    function testVerifyCertificateFailsWithWrongData() public {
        vm.prank(university);
        credentialSystem.issueCertificate(
            student,
            "Aditya Ingole",
            "Blockchain",
            "B.Tech",
            "ipfs://Qm123..."
        );

        uint256[] memory certIds = credentialSystem.getStudentCertificateIds(student);
        uint256 certId = certIds[0];

        // Wrong course
        bool valid = credentialSystem.verifyCertificate(
            certId,
            "Aditya Ingole",
            student,
            "AI & ML",
            "B.Tech",
            "ipfs://Qm123..."
        );

        assertFalse(valid);
    }

    function testMultipleCertificatesPerStudent() public {
        vm.prank(university);

        credentialSystem.issueCertificate(student, "Aditya", "Blockchain", "B.Tech", "ipfs://hash1");
        credentialSystem.issueCertificate(student, "Aditya", "AI & ML", "B.Tech", "ipfs://hash2");

        uint256[] memory certIds = credentialSystem.getStudentCertificateIds(student);
        assertEq(certIds.length, 2);
    }

    function testOnlyAdminCanAddUniversity() public {
        // Hacker tries to add themselves as university
        vm.expectRevert();
        vm.prank(hacker);
        credentialSystem.addUniversity(hacker);

        // Admin adds
        vm.prank(deployer);
        credentialSystem.addUniversity(hacker);

        // Now hacker can issue
        vm.prank(hacker);
        credentialSystem.issueCertificate(
            student,
            "Aditya",
            "Cybersecurity",
            "B.Tech",
            "ipfs://x"
        );
    }

    function testOnlyAdminCanRevokeUniversity() public {
        vm.prank(deployer);
        credentialSystem.addUniversity(hacker);

        // Admin revokes hacker
        vm.prank(deployer);
        credentialSystem.revokeUniversity(hacker);

        // Hacker should now be blocked
        vm.expectRevert();
        vm.prank(hacker);
        credentialSystem.issueCertificate(
            student,
            "Blocked",
            "Malware Engineering",
            "PhD",
            "ipfs://bad"
        );
    }
}
