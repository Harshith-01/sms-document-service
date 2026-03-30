# Document Service

This microservice handles the management, uploads, verification, and deletion of documents across the centralized school database. It stores the document files securely in Cloudinary, while tying robust relational metadata to `student`, `teacher`, and `admin` records in a shared PostgreSQL database.

## Features
- **Cloudinary Integration**: Upload and fetch file URLs dynamically.
- **Strict Relational Integrity**: A unified `documents` table leverages hard Foreign Keys mapped directly to `public.students`, `public.teachers`, and `public.admin`, with database `CHECK` constraints barring invalid entries.
- **API Security**: Includes global rate limiting (via `SlowAPI`), strict CORS and Trusted Host validations, and a firm 15MB file upload limit to prevent overload.
- **Containerized Network**: Fully packaged utilizing Docker structures. Runs safely on port `8004` (while linking to internal DB port 5434 on the host).

## Running Locally

To spin up the service along with its PostgreSQL backing store, simply invoke:

```bash
docker-compose up -d --build
```

You can then test the secure endpoints interactively by navigating to the OpenAPI schema at:
`http://localhost:8004/docs`

## Environment Setup
Duplicate the `.env.example` file and designate it as `.env`. Do not forget to populate the necessary Cloudinary variables securely. 

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=document_db
DATABASE_URL=postgresql://postgres:password@document-db:5432/document_db

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8004
ALLOWED_HOSTS=localhost,127.0.0.1,document-service

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

## Important Database Rules
The PostgreSQL schema generated in `db-init/init.sql` actively prohibits orphaned documents. To successfully use the `POST /api/documents/upload` endpoint, the `entity_id` you pass in **must** correspond perfectly to an existing record inside the base schema's tables (`students`, `teachers`, or `admin`). Failure to accommodate this will reject the document upload at the database layer (a `psycopg2` Foreign Key Violation) to guarantee long-term system consistency.
