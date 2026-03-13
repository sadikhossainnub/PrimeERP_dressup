import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
    CallToolRequestSchema,
    ListToolsRequestSchema,
    Tool,
} from "@modelcontextprotocol/sdk/types.js";
import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const ERPNEXT_URL = process.env.ERPNEXT_URL;
const API_KEY = process.env.API_KEY;
const API_SECRET = process.env.API_SECRET;

if (!ERPNEXT_URL || !API_KEY || !API_SECRET) {
    console.error("Missing required environment variables: ERPNEXT_URL, API_KEY, API_SECRET");
    process.exit(1);
}

const axiosInstance = axios.create({
    baseURL: ERPNEXT_URL,
    headers: {
        Authorization: `token ${API_KEY}:${API_SECRET}`,
        "Content-Type": "application/json",
        Accept: "application/json",
    },
});

const server = new Server(
    {
        name: "primeerp-mcp",
        version: "1.0.0",
    },
    {
        capabilities: {
            tools: {},
        },
    }
);

const GET_LIST_TOOL: Tool = {
    name: "erpnext_get_list",
    description: "Fetch a list of documents for a given DocType with optional filters and fields",
    inputSchema: {
        type: "object",
        properties: {
            doctype: { type: "string" },
            fields: { type: "array", items: { type: "string" } },
            filters: { type: "array", items: { type: "array" } },
            limit_page_length: { type: "number", default: 20 },
        },
        required: ["doctype"],
    },
};

const GET_DOC_TOOL: Tool = {
    name: "erpnext_get_doc",
    description: "Fetch a single document by its DocType and name",
    inputSchema: {
        type: "object",
        properties: {
            doctype: { type: "string" },
            name: { type: "string" },
        },
        required: ["doctype", "name"],
    },
};

const CALL_METHOD_TOOL: Tool = {
    name: "erpnext_call_method",
    description: "Call an arbitrary whitelisted python method on Frappe backend",
    inputSchema: {
        type: "object",
        properties: {
            method: { type: "string" },
            data: { type: "object" },
        },
        required: ["method"],
    },
};

server.setRequestHandler(ListToolsRequestSchema, async () => ({
    tools: [GET_LIST_TOOL, GET_DOC_TOOL, CALL_METHOD_TOOL],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;

    try {
        if (name === "erpnext_get_list") {
            const { doctype, fields, filters, limit_page_length } = args as any;
            const params: any = { limit_page_length: limit_page_length || 20 };
            if (fields) params.fields = JSON.stringify(fields);
            if (filters) params.filters = JSON.stringify(filters);

            const response = await axiosInstance.get(`/api/resource/${doctype}`, { params });
            return {
                content: [{ type: "text", text: JSON.stringify(response.data, null, 2) }],
            };
        }

        if (name === "erpnext_get_doc") {
            const { doctype, name: docName } = args as any;
            const response = await axiosInstance.get(`/api/resource/${doctype}/${docName}`);
            return {
                content: [{ type: "text", text: JSON.stringify(response.data, null, 2) }],
            };
        }

        if (name === "erpnext_call_method") {
            const { method, data } = args as any;
            const response = await axiosInstance.post(`/api/method/${method}`, data || {});
            return {
                content: [{ type: "text", text: JSON.stringify(response.data, null, 2) }],
            };
        }

        throw new Error(`Unknown tool: ${name}`);
    } catch (error: any) {
        const errorMsg = error.response?.data ? JSON.stringify(error.response.data) : error.message;
        return {
            content: [{ type: "text", text: `Error calling ERPNext API: ${errorMsg}` }],
            isError: true,
        };
    }
});

async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("PrimeERP MCP Server running on stdio");
}

main().catch((error) => {
    console.error("Fatal error in main():", error);
    process.exit(1);
});
