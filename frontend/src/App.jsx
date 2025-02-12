import { useState, useEffect } from "react";
import { ethers } from "ethers";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const contractABI = [ /* Your ABI here */ ];
const contractAddress = "0xYourSmartContractAddress";

export default function App() {
    const [account, setAccount] = useState(null);
    const [holder, setHolder] = useState("");
    const [credentialHash, setCredentialHash] = useState("");
    const [credentialId, setCredentialId] = useState("");
    const [verificationResult, setVerificationResult] = useState("");
    const [isIssuer, setIsIssuer] = useState(false);

    useEffect(() => {
        if (window.ethereum) {
            window.ethereum.request({ method: "eth_accounts" }).then(accounts => {
                if (accounts.length) {
                    setAccount(accounts[0]);
                }
            });
        }
    }, []);

    async function connectWallet() {
        if (window.ethereum) {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const accounts = await provider.send("eth_requestAccounts", []);
            setAccount(accounts[0]);
        } else {
            alert("MetaMask not detected!");
        }
    }

    async function issueCredential() {
        if (!holder || !credentialHash) return alert("Fill all fields");
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(contractAddress, contractABI, signer);
        
        const tx = await contract.issueCredential(holder, credentialHash);
        const receipt = await tx.wait();
        alert(`Credential issued! TX Hash: ${receipt.transactionHash}`);
    }

    async function verifyCredential() {
        if (!credentialId) return alert("Enter a credential ID");
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const contract = new ethers.Contract(contractAddress, contractABI, provider);
        
        const [isValid, hash, issuer, holder] = await contract.verifyCredential(credentialId);
        setVerificationResult(isValid ? `✅ Valid Credential issued by ${issuer}` : "❌ Revoked Credential");
    }

    return (
        <div className="flex flex-col items-center min-h-screen bg-gray-100 p-6">
            <Button onClick={connectWallet} className="mb-4">
                {account ? `Connected: ${account}` : "Connect Wallet"}
            </Button>
            
            {isIssuer && (
                <Card className="w-full max-w-md p-4">
                    <CardContent>
                        <h2 className="text-xl font-bold mb-2">Issue Credential</h2>
                        <Input type="text" placeholder="Holder Address" value={holder} onChange={(e) => setHolder(e.target.value)} />
                        <Input type="text" placeholder="Credential Hash" value={credentialHash} onChange={(e) => setCredentialHash(e.target.value)} className="mt-2" />
                        <Button onClick={issueCredential} className="mt-2">Issue</Button>
                    </CardContent>
                </Card>
            )}
            
            <Card className="w-full max-w-md p-4 mt-4">
                <CardContent>
                    <h2 className="text-xl font-bold mb-2">Verify Credential</h2>
                    <Input type="text" placeholder="Enter Credential ID" value={credentialId} onChange={(e) => setCredentialId(e.target.value)} />
                    <Button onClick={verifyCredential} className="mt-2">Verify</Button>
                    <p className="mt-2 text-center">{verificationResult}</p>
                </CardContent>
            </Card>
        </div>
    );
}
