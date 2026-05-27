CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS documents (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filename      TEXT NOT NULL,
    source_type   TEXT NOT NULL CHECK (source_type IN ('pdf', 'word', 'web')),
    source_url    TEXT,
    uploaded_at   TIMESTAMPTZ DEFAULT NOW(),
    status        TEXT NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending', 'processed', 'failed')),
    error_message TEXT
);

CREATE TABLE IF NOT EXISTS chunks (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id   UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    content       TEXT NOT NULL,
    chunk_index   INTEGER NOT NULL,
    token_count   INTEGER,
    embedding_id  TEXT,
    created_at    TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE (document_id, chunk_index)
);

CREATE TABLE IF NOT EXISTS query_logs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question      TEXT NOT NULL,
    answer        TEXT NOT NULL,
    chunks_used   UUID[],
    latency_ms    INTEGER,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chunks_document_id ON chunks(document_id);
CREATE INDEX IF NOT EXISTS idx_documents_status   ON documents(status);
CREATE INDEX IF NOT EXISTS idx_query_logs_date    ON query_logs(created_at DESC);
