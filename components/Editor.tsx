import CodeMirror from "@uiw/react-codemirror";
import { python } from "@codemirror/lang-python";
import { createTheme } from "@uiw/codemirror-themes";
import { tags as t } from "@lezer/highlight";
import { Button } from "@radix-ui/themes";
import React, { useState } from "react";
import styles from "./Editor.module.css";

const myTheme = createTheme({
  theme: "light",
  settings: {
    background: "#202123",
    foreground: "#ffff",
    caret: "#ffffff",
    selection: "#036dd626",
    selectionMatch: "#036dd626",
    lineHighlight: "#202123",
    gutterBackground: "#202123",
    gutterForeground: "#8a919966",
  },
  styles: [
    { tag: t.comment, color: "#6a737d" }, // Greyed-out text for comments
    { tag: t.variableName, color: "#79b8ff" }, // Light blue for variable names
    { tag: [t.string, t.special(t.brace)], color: "#ce9178" }, // Strings get a slightly reddish color
    { tag: t.number, color: "#b5cea8" }, // Numbers in a green shade
    { tag: t.bool, color: "#d16969" }, // Booleans in reddish color
    { tag: t.null, color: "#d16969" }, // Null in reddish too
    { tag: t.keyword, color: "#c586c0" }, // Purple for keywords
    { tag: t.operator, color: "#d4d4d4" }, // Light grey for operators
    { tag: t.className, color: "#4ec9b0" }, // Teal for class names
    { tag: t.definition(t.typeName), color: "#4ec9b0" }, // Teal for type names when they're defined
    { tag: t.typeName, color: "#4ec9b0" }, // Teal for type names
    { tag: t.angleBracket, color: "#d7ba7d" }, // Angle brackets in a sort of tan
    { tag: t.tagName, color: "#569cd6" }, // Tag names in a darker blue
    { tag: t.attributeName, color: "#9cdcfe" }, // Lighter blue for attribute names
  ],
});

const pyLang = `import OpenAI from 'openai';

const openai = new OpenAI();

async function main() {
  const completion = await openai.chat.completions.create({
    messages: [{ role: 'user', content: 'Say this is a test' }],
    model: 'gpt-4o-mini',
    max_tokens: 256,
  });

  return completion.choices;
}

main();`;

export default function Editor() {
  const [codeContent, setCodeContent] = useState(pyLang);
  const [executeToken, setExecuteToken] = useState("");
  const [result, setResult] = useState<unknown>(null);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const fetchCode = async () => {
    setLoading(true);
    setError("");
    setResult(null);

    try {
      const res = await fetch("/api/execute/code", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${executeToken.trim()}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ code: codeContent }),
      });
      const data = await res.json();
      if (!res.ok) {
        throw new Error(data?.error || "Request failed");
      }
      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Request failed");
    } finally {
      setLoading(false);
    }
  };
  const formattedResult = result ? JSON.stringify(result, null, 2) : "";

  return (
    <>
      <CodeMirror
        value={codeContent}
        theme={myTheme}
        extensions={[python()]}
        onChange={(value) => {
          setCodeContent(value);
        }}
      />
      <div className={styles.controls}>
        <label className={styles.tokenLabel}>
          Execute token
          <input
            className={styles.tokenInput}
            type="password"
            autoComplete="off"
            value={executeToken}
            onChange={(event) => setExecuteToken(event.target.value)}
          />
        </label>
        {/* have the button make a call to the fetchCode function */}
        <Button
          onClick={fetchCode}
          style={{ backgroundColor: "#0CA37F", color: "#fff" }}
          disabled={loading || executeToken.trim() === ""}
        >
          {loading ? (
            // Spinner SVG or another spinner component
            <div className={styles.spinner}></div>
          ) : (
            <svg
              width="15"
              height="15"
              viewBox="0 0 15 15"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M3.24182 2.32181C3.3919 2.23132 3.5784 2.22601 3.73338 2.30781L12.7334 7.05781C12.8974 7.14436 13 7.31457 13 7.5C13 7.68543 12.8974 7.85564 12.7334 7.94219L3.73338 12.6922C3.5784 12.774 3.3919 12.7687 3.24182 12.6782C3.09175 12.5877 3 12.4252 3 12.25V2.75C3 2.57476 3.09175 2.4123 3.24182 2.32181ZM4 3.57925V11.4207L11.4288 7.5L4 3.57925Z"
                fill="currentColor"
                fillRule="evenodd"
                clipRule="evenodd"
              ></path>
            </svg>
          )}
          Run
        </Button>
      </div>
      {error && <pre>{error}</pre>}
      {result && (
        <CodeMirror
          value={formattedResult}
          theme={myTheme}
          extensions={[python()]}
          readOnly
        />
      )}
    </>
  );
}
