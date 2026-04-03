# Document Service

This microservice handles upload, retrieval, verification, and deletion of documents for the centralized school database. Files are stored in Cloudinary, while metadata is stored in PostgreSQL.

## Features
- **Cloudinary Integration**: Upload and fetch file URLs dynamically.
- **Role-secure API**: JWT-based access with support for self-service and admin-managed uploads.
- **Profile Photo Workflow**: Profile photos are auto-verified and limited to one active photo per entity.
- **Verification Workflow**: Non-profile documents can be verified/rejected by admin roles.
- **Security Middleware**: Global rate limiting (SlowAPI), strict CORS and Trusted Host validations, and a 15MB upload size limit.
- **Containerized Network**: Fully packaged utilizing Docker structures. Runs safely on port `8004` (while linking to internal DB port 5434 on the host).

## Running Locally

To run locally:

```bash
docker-compose up -d --build
```

You can then test the secure endpoints interactively by navigating to the OpenAPI schema at:
`http://localhost:8004/docs`

## Environment Setup
Duplicate the `.env.example` file and designate it as `.env`. Do not forget to populate the necessary Cloudinary variables securely. 

```env
DATABASE_URL=postgresql://postgres:password@localhost:5432/school_db
SECRET_KEY=match_auth_service_secret
INTERNAL_SERVICE_TOKEN=
INTERNAL_ALLOWED_SERVICES=auth-service,academic-service,student-service,teacher-service,assessment-service,attendance-service,parent-service,staff-service,fees-service,document-service

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8004
ALLOWED_HOSTS=localhost,127.0.0.1,document-service

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## Important Database Rules
For MVP, upload/list operations are currently enabled for student and teacher entities. Parent and non-teaching staff document flows can be enabled later without breaking the current table design.
