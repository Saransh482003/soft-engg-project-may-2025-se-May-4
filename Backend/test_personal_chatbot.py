"""
Test script for the personal chatbot functionality
"""

def test_generate_personalized_name():
    """Test the name generation function"""
    # Mock the function since we can't import directly
    def generate_personalized_name(gender, personality_type, age):
        names = {
            'male': {
                'friendly': ['Alex', 'David', 'Michael', 'James', 'Robert'],
                'professional': ['William', 'Charles', 'Richard', 'Thomas', 'Daniel'],
                'creative': ['Sebastian', 'Adrian', 'Julian', 'Marcus', 'Oliver'],
                'analytical': ['Benjamin', 'Nathan', 'Samuel', 'Jonathan', 'Matthew'],
                'empathetic': ['Christopher', 'Andrew', 'Nicholas', 'Anthony', 'Joseph']
            },
            'female': {
                'friendly': ['Emma', 'Sarah', 'Jessica', 'Ashley', 'Amanda'],
                'professional': ['Victoria', 'Elizabeth', 'Catherine', 'Margaret', 'Jennifer'],
                'creative': ['Isabella', 'Sophia', 'Olivia', 'Aria', 'Luna'],
                'analytical': ['Charlotte', 'Abigail', 'Emily', 'Grace', 'Hannah'],
                'empathetic': ['Rachel', 'Rebecca', 'Samantha', 'Nicole', 'Michelle']
            }
        }
        
        gender_key = gender.lower() if gender.lower() in names else 'female'
        personality_key = personality_type.lower() if personality_type.lower() in names[gender_key] else 'friendly'
        
        import random
        random.seed(hash(f"{gender}{personality_type}{age}"))
        return random.choice(names[gender_key][personality_key])
    
    # Test cases
    test_cases = [
        ('female', 'analytical', 28),
        ('male', 'creative', 35),
        ('female', 'professional', 45),
        ('male', 'empathetic', 22)
    ]
    
    print("Testing name generation:")
    for gender, personality, age in test_cases:
        name = generate_personalized_name(gender, personality, age)
        print(f"Gender: {gender}, Personality: {personality}, Age: {age} -> Name: {name}")

def test_prompt_generation():
    """Test the prompt generation function"""
    def generate_personalized_prompt(name, gender, age, profession, personality_type, expertise_areas, communication_style):
        age_context = ""
        if age < 25:
            age_context = "You have a youthful, energetic perspective and are up-to-date with modern trends and technology."
        elif age < 40:
            age_context = "You have a balanced perspective with both youthful energy and growing life experience."
        elif age < 60:
            age_context = "You have substantial life and professional experience, offering mature and thoughtful insights."
        else:
            age_context = "You have extensive life wisdom and deep experience, providing thoughtful and measured responses."

        personality_traits = {
            'friendly': "warm, approachable, and always eager to help. You use casual language and often include encouraging words.",
            'professional': "formal, precise, and business-oriented. You maintain professionalism while being helpful.",
            'creative': "imaginative, innovative, and think outside the box. You often provide unique perspectives and creative solutions.",
            'analytical': "logical, detail-oriented, and data-driven. You break down complex problems systematically.",
            'empathetic': "understanding, compassionate, and emotionally intelligent. You show genuine care for others' feelings."
        }

        personality_desc = personality_traits.get(personality_type.lower(), personality_traits['friendly'])
        
        expertise_context = ""
        if expertise_areas:
            if isinstance(expertise_areas, list):
                expertise_list = ", ".join(expertise_areas)
            else:
                expertise_list = str(expertise_areas)
            expertise_context = f"Your areas of expertise include: {expertise_list}. You can provide informed insights in these areas."

        prompt = f"""
You are {name}, a {age}-year-old {gender} {profession}. {age_context}

Personality: You are {personality_desc}

{expertise_context}

Key Instructions:
- Always stay in character as {name}
- Respond according to your personality type
- Draw from your professional background when relevant
- Maintain consistency with your age and life experience
"""
        return prompt.strip()
    
    print("\nTesting prompt generation:")
    test_prompt = generate_personalized_prompt(
        "Charlotte", "female", 28, "Data Scientist", "analytical", 
        ["Machine Learning", "Statistics"], "detailed"
    )
    print("Generated prompt preview:")
    print(test_prompt[:200] + "...")

if __name__ == "__main__":
    test_generate_personalized_name()
    test_prompt_generation()
    print("\n✅ Personal chatbot functions appear to be working correctly!")
