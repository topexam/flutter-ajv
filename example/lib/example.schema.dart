const exampleFormSchema = {
  "required": ["name", "age", "id", "email", "student", "worker"],
  "properties": {
    "id": {"minimum": 0, "type": "number"},
    "name": {"type": "string"},
    "email": {"type": "string", "format": "email"},
    "age": {"minimum": 0, "type": "number"},
    "student": {"type": "boolean"},
    "worker": {"type": "boolean"}
  }
};

const exampleFormData = {
  "id": -1,
};
