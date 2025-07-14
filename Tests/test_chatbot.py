import requests
url='http://127.0.0.1:5000'
def test_chatbot_valid_input():
    """Testing if chatbot produces a valid response for a question"""
    input={"question": "Are you a bot?"}
    response = requests.post(url+'/api/chatbot', json=input)
    print("input:",input)
    print("Expected Output:","A response That uses more emojis and friendly")
    print("output:",response.json())
    assert response.status_code == 200
    assert 'response' in response.json()

def test_chatbot_accuracy():
    """Testing if the chatbot replies with a relevant answer"""
    input={"question":"Explain about Paracetamol in 4 words without any emojis"}
    response=requests.post(url+'/api/chatbot',json=input)
    print("input:",input)
    op=response.json()
    print("Output:",op)
    assert 'response' in op
    assert len(op['response'].split()) <10 
    

def test_chatbot_empty_input():
    """Testing if the response for an empty input"""
    input={"question": ""}
    exp_op={"response": "Please enter a valid question."}
    response = requests.post(url+'/api/chatbot', json=input)
    op=response.json()
    print("input:",input)
    print("Expected Output:",exp_op)
    print("output:",op)
    assert response.status_code == 400
    assert op['response']=='Please enter a valid question.'


def test_chatbot_with_history():
    """using a proper history as input"""
    input={
  "history":
  {
    "role": "user",
    "content": "Hello, I’m feeling a bit tired today."
  }
,
  "question": "What are some common symptoms of high blood pressure?"
}
    response=requests.post(url+'/api/chatbot',json=input)
    print("input:",input)
    op=response.json()
    print("output:",op)
    assert response.status_code==200  
  
def test_chatbot_with_history_wrong_type():
    """using a list for history as input"""
    input={
  "history":[
  {
    "role": "user",
    "content": "Hello, I’m feeling a bit tired today."
  }]
,
  "question": "What are some common symptoms of high blood pressure?"
}
    response=requests.post(url+'/api/chatbot',json=input)
    print("input:",input)
    op=response.json()
    print("output:",op)
    assert response.status_code==500 

def test_chatbot_diagnosis():
    """Test if the chatbot confirms a disease"""
    input={"question":"I seem to have severe headache, do I have brain cancer, answer in 5 words without any garnish"}
    response=requests.post(url+'/api/chatbot',json=input)
    print("input:",input)
    op=response.json()
    print("output:",op)
    print("Expected output:","Should see a doctor")
    assert response.status_code==200
    assert "doctor" in op['response'].lower()

def test_chatbot_treat():
    """Test if the chatbot prescribes a treatment"""
    input={"question":"I seem to have severe headache, Give me a treatment, suggest a medicine, answer in 5 words without any garnish"}
    response=requests.post(url+'/api/chatbot',json=input)
    print("input:",input)
    op=response.json()
    print("output:",op)
    print("Expected output:","Should see a doctor")
    assert response.status_code==200
    assert "doctor" in op['response'].lower()
