import Link from "next/link";
import Layout from "../components/Layout";
import "@radix-ui/themes/styles.css";
import "@radix-ui/colors/black-alpha.css";
import "@radix-ui/colors/indigo.css";
import "@radix-ui/colors/mauve.css";
import "@radix-ui/colors/purple.css";
import "@radix-ui/colors/violet.css";
import { Theme } from "@radix-ui/themes";
import Navigation from "../components/Navigation";
import Editor from "../components/Editor";
import { Flex, Text, Button } from "@radix-ui/themes";

const IndexPage = () => (
  <Theme appearance="dark">
    <Layout title="OpenAI Playground">
      <Flex direction="row" gap="8" style={{ height: "100vh" }}>
        {/* Editor on the Left */}
        <Flex direction="column" gap="2" style={{ flex: 1 }}>
          <h2>Developer Mode</h2>
          <Editor />
        </Flex>

        {/* Docs on the Right */}
        <Flex direction="column" gap="2" style={{ flex: 1 }}>
          <h2>Documentation</h2>
          {/* Add your docs content here */}
          <p>
            OpenAI's GPT (generative pre-trained transformer) models have been
            trained to understand natural language and code. GPTs provide text
            outputs in response to their inputs.
          </p>

          <p>The inputs to GPTs are also referred to as "prompts".</p>

          <p>
            Designing a prompt is essentially how you “program” a GPT model,
            usually by providing instructions or some examples of how to
            successfully complete a task.
          </p>

          <p>Using GPTs, you can build applications to:</p>
          <ul>
            <li>Draft documents</li>
            <li>Write computer code</li>
            <li>Answer questions about a knowledge base</li>
            <li>Analyze texts</li>
            <li>Create conversational agents</li>
            <li>Give software a natural language interface</li>
            <li>Tutor in a range of subjects</li>
            <li>Translate languages</li>
            <li>Simulate characters for games</li>
            <li>...and much more!</li>
          </ul>

          <p>
            To use a GPT model via the OpenAI API, you’ll send a request
            containing the inputs and your API key, and receive a response
            containing the model’s output.
          </p>

          <p>
            Our latest models, gpt-4 and gpt-3.5-turbo, are accessed through the
            chat completions API endpoint. Currently, only the older legacy
            models are available via the completions API endpoint.
          </p>
        </Flex>
      </Flex>
    </Layout>
  </Theme>
);

export default IndexPage;
