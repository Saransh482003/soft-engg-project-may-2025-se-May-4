import os
from dotenv import load_dotenv
from groq import Groq
import json

load_dotenv()

class Chatbot:
    def __init__(self, api_key, system_prompt=""):
        self.api_key = api_key
        self.client = Groq(api_key=self.api_key)
        self.system_prompt = system_prompt

    def get_response(self, user_input, history={"user": "", "assistant": ""}):
        chat_completion = self.client.chat.completions.create(
            messages=[
                {

                "role": "system",
                "content": self.system_prompt
                },
                {
                    "role": "user",
                    "content": history.get("user", ""),
                },
                {
                    "role": "assistant",
                    "content": history.get("assistant", ""),
                },
                {
                    "role": "user",
                    "content": user_input,
                }
            ],
            model="llama-3.3-70b-versatile",
        )
        try:
            response = chat_completion.choices[0].message.content
            return response
        except Exception as e:
            return f"Error: {str(e)}"

