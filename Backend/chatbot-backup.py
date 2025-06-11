import os
from langchain_core.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain_groq import ChatGroq  # pip install langchain-groq
from dotenv import load_dotenv,dotenv_values
from langchain_core.runnables import RunnableSequence

# Set your Groq API key
load_dotenv()
os.environ["GROQ_API_KEY"] = os.getenv("GROQ_API_KEY")
# SYSTEM PROMPT designed for senior citizens
SYSTEM_PROMPT = (
    "You are a kind, patient, and helpful assistant for senior citizens. "
    "Always respond clearly and politely, using simple language. "
)

# Prompt template using instruct-style structure
full_prompt_template = PromptTemplate(
    input_variables=["user_input"],
    template=(
        "<|system|>\n"
        f"{SYSTEM_PROMPT}\n"
        "<|user|>\n"
        "{user_input}\n"
        "<|assistant|>\n"
    )
)

# Load LLaMA 3 model from Groq
llm = ChatGroq(model_name="llama3-70b-8192")

# Create the chatbot chain
chatbot_chain = full_prompt_template | llm

# Function to use in Flask or elsewhere
def get_chatbot_response(user_input: str) -> str:
    try:
        response = chatbot_chain.invoke({"user_input": user_input})
        return response.content.strip()
    except Exception as e:
        return f"Error: {str(e)}"
