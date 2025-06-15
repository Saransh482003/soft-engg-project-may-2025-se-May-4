# chatbot.py

import os
from dotenv import load_dotenv
from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.messages import HumanMessage, AIMessage
from langchain_community.chat_message_histories import ChatMessageHistory

# Load environment variables
load_dotenv()
groq_api_key = os.getenv("GROQ_API_KEY")

# Load LLaMA3 model from Groq
llm = ChatGroq(
    model_name="llama3-70b-8192",
    temperature=0.6,
    api_key=groq_api_key,
)

# Define system prompt
SYSTEM_PROMPT = (
    "You are a kind, patient, and helpful assistant for senior citizens. "
    "Always respond clearly and politely, using simple language."
)

# Chat prompt template with memory support
prompt = ChatPromptTemplate.from_messages([
    ("system", SYSTEM_PROMPT),
    MessagesPlaceholder(variable_name="history"),
    ("human", "{user_input}")
])

store={}
# Function to return a ChatMessageHistory for each session
def get_session_history(session_id: str) -> ChatMessageHistory:
    if session_id not in store:
        store[session_id] = ChatMessageHistory()
    return store[session_id]

# Combine the prompt and model into a memory-aware runnable
chain = prompt | llm
chatbot_chain = RunnableWithMessageHistory(
    chain,
    get_session_history,
    input_messages_key="user_input",
    history_messages_key="history"
)

# Function to call from your Flask route
def get_chatbot_response(user_input: str, session_id: str = "default") -> str:
    try:
        response = chatbot_chain.invoke(
            {"user_input": user_input},
            config={"configurable": {"session_id": session_id}}
        )
        return response.content.strip()
    except Exception as e:
        return f"Error: {str(e)}"
