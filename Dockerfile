FROM python:3.7
EXPOSE 5000
COPY /app/app.py /app
COPY /app/requirements.txt /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD python app.py
