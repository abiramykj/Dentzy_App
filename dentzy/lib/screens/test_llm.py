from google import genai

client = genai.Client(api_key="AIzaSyA0p246p__Gfpkc6U2llLGM3zaHCdRIs_k")

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Is brushing teeth twice a day good?"
)

print(response.text)