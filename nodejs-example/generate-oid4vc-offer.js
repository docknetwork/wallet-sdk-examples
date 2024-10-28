const axios = require("axios").default;

const API_KEY = process.env.CERTS_API_KEY;
const API_URL = process.env.CERTS_API_URL;

const requestOptions = {
  headers: {
    "Content-Type": "application/json",
    "User-Agent": "insomnia/9.3.2",
    "DOCK-API-TOKEN": API_KEY,
  },
};

const apiClient = axios.create({
  baseURL: API_URL,
  headers: requestOptions.headers,
});

async function createOpenIDIssuer() {
  try {
    const response = await apiClient.post("/openid/issuers", {
      claimMap: { name: "name" },
      credentialOptions: {
        credential: {
          type: ["MyCredential"],
          subject: { id: "test", test: "test" },
          issuanceDate: "2024-08-09T14:15:22Z",
          expirationDate: "2099-08-24T14:15:22Z",
          schema: "https://schema.dock.io/Test-V1-1701450859791.json",
          issuer: "did:dock:5CkQ14QjBuuidYJPC7uRMhN1Hrtv3kTLuUx8dGsnNgm4RtT5",
        },
      },
    });
    console.log(`OpenID issuer ${response.data.id} was created.`);
    return response.data;
  } catch (error) {
    console.error("Failed to create OpenID issuer:", error);
  }
}

async function generateOID4VCOffer() {
  try {
    const response = await apiClient.post("/openid/credential-offers", {
      id: "2baff124-6681-428b-b5a1-449f211d9624",
    });
    console.log(`OID4VC offer ${response.data.id} was created.`);
    console.log(`Copy your OID4VC URL: ${response.data.url}`);
    return response.data;
  } catch (error) {
    console.error("Failed to generate OID4VC offer:", error);
  }
}

async function main() {
  await createOpenIDIssuer();
  await generateOID4VCOffer();
}

main();
