return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mfussenegger/nvim-jdtls",
  },
  opts = {
    servers = {
      jdtls = {},
    },
    setup = {
      jdtls = function()
        -- Get the Mason Registry to gain access to downloaded binaries
        local mason_registry = require("mason-registry")

        -- Function to get JDTLS paths
        local function get_jdtls()
          -- Find the JDTLS package in the Mason Registry
          local jdtls = mason_registry.get_package("jdtls")
          -- Find the full path to the directory where Mason has downloaded the JDTLS binaries
          local jdtls_path = jdtls:get_install_path()
          -- Obtain the path to the jar which runs the language server
          local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
          -- Declare which operating system we are using, windows use win, macos use mac
          local SYSTEM = "linux"
          -- Obtain the path to configuration files for your specific operating system
          local config = jdtls_path .. "/config_" .. SYSTEM
          -- Obtain the path to the Lombok jar
          local lombok = jdtls_path .. "/lombok.jar"
          return launcher, config, lombok
        end
        local function java_keymaps()
          -- Allow yourself to run JdtCompile as a Vim command
          -- vim.cmd(
          --   "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
          -- )
          -- -- Allow yourself/register to run JdtUpdateConfig as a Vim command
          -- vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
          -- -- Allow yourself/register to run JdtBytecode as a Vim command
          -- vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
          -- -- Allow yourself/register to run JdtShell as a Vim command
          -- vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")

          -- Set a Vim motion to <Space> + <Shift>J + o to organize imports in normal mode
          -- vim.keymap.set(
          --   "n",
          --   "<C-S-i>",
          --   "<Cmd> lua require('jdtls').organize_imports()<CR>",
          --   { desc = "[J]ava [O]rganize Imports" }
          -- )
          -- vim.keymap.set(
          --   "n",
          --   "<C-S-i>",
          --   "<Cmd> lua require('jdtls').organize_imports()<CR>",
          --   { desc = "[J]ava [O]rganize Imports" }
          -- )

          -- Set a Vim motion to <Space> + <Shift>J + v to extract the code under the cursor to a variable
          -- vim.keymap.set(
          --   "n",
          --   "<leader>Jv",
          --   "<Cmd> lua require('jdtls').extract_variable()<CR>",
          --   { desc = "[J]ava Extract [V]ariable" }
          -- )
          -- -- Set a Vim motion to <Space> + <Shift>J + v to extract the code selected in visual mode to a variable
          -- vim.keymap.set(
          --   "v",
          --   "<leader>Jv",
          --   "<Esc><Cmd> lua require('jdtls').extract_variable(true)<CR>",
          --   { desc = "[J]ava Extract [V]ariable" }
          -- )
          -- Set a Vim motion to <Space> + <Shift>J + <Shift>C to extract the code under the cursor to a static variable
          -- vim.keymap.set(
          --   "n",
          --   "<leader>JC",
          --   "<Cmd> lua require('jdtls').extract_constant()<CR>",
          --   { desc = "[J]ava Extract [C]onstant" }
          -- )
          -- Set a Vim motion to <Space> + <Shift>J + <Shift>C to extract the code selected in visual mode to a static variable
          -- vim.keymap.set(
          --   "v",
          --   "<leader>JC",
          --   "<Esc><Cmd> lua require('jdtls').extract_constant(true)<CR>",
          --   { desc = "[J]ava Extract [C]onstant" }
          -- )
          -- Set a Vim motion to <Space> + <Shift>J + t to run the test method currently under the cursor
          -- vim.keymap.set(
          --   "n",
          --   "<leader>Jt",
          --   "<Cmd> lua require('jdtls').test_nearest_method()<CR>",
          --   { desc = "[J]ava [T]est Method" }
          -- )
          -- Set a Vim motion to <Space> + <Shift>J + t to run the test method that is currently selected in visual mode
          -- vim.keymap.set(
          --   "v",
          --   "<leader>Jt",
          --   "<Esc><Cmd> lua require('jdtls').test_nearest_method(true)<CR>",
          --   { desc = "[J]ava [T]est Method" }
          -- )
          -- Set a Vim motion to <Space> + <Shift>J + <Shift>T to run an entire test suite (class)
          -- vim.keymap.set("n", "<leader>JT", "<Cmd> lua require('jdtls').test_class()<CR>", { desc = "[J]ava [T]est Class" })
          -- Set a Vim motion to <Space> + <Shift>J + u to update the project configuration
          -- vim.keymap.set("n", "<leader>Ju", "<Cmd> JdtUpdateConfig<CR>", { desc = "[J]ava [U]pdate Config" })
        end
        -- Function to get workspace directory
        local function get_workspace()
          -- Get the home directory of your operating system
          local home = os.getenv("HOME")
          -- Declare a directory where you would like to store project information
          local workspace_path = home .. "/code/workspace/"
          -- Determine the project name
          local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
          -- Create the workspace directory by concatenating the designated workspace path and the project name
          local workspace_dir = workspace_path .. project_name
          return workspace_dir
        end

        -- Setup function for JDTLS
        local function setup_jdtls()
          local jdtls = require("jdtls")

          -- Get paths for jdtls
          local launcher, os_config, lombok = get_jdtls()

          -- Get workspace directory
          local workspace_dir = get_workspace()

          -- Determine the root directory of the project
          local root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })

          -- Extended client capabilities
          local extendedClientCapabilities = jdtls.extendedClientCapabilities
          extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

          -- JDTLS start command
          local cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xmx1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-javaagent:" .. lombok,
            "-jar",
            launcher,
            "-configuration",
            os_config,
            "-data",
            workspace_dir,
          }

          -- JDTLS settings
          local settings = {
            java = {
              format = { enabled = false },
              eclipse = { downloadSource = true },
              maven = { downloadSources = true },
              signatureHelp = { enabled = true },
              contentProvider = { preferred = "fernflower" },
              saveActions = { organizeImports = true },
              completion = {
                favoriteStaticMembers = {
                  "org.hamcrest.MatcherAssert.assertThat",
                  "org.hamcrest.Matchers.*",
                  "org.hamcrest.CoreMatchers.*",
                  "org.junit.jupiter.api.Assertions.*",
                  "java.util.Objects.*",
                  "java.util.Objects.requireNonNull",
                  "java.util.Objects.requireNonNullElse",
                  "org.mockito.Mockito.*",
                },
                filteredTypes = {
                  "com.sun.*",
                  "io.micrometer.shaded.*",
                  "java.awt.*",
                  "jdk.*",
                  "sun.*",
                },
                importOrder = {
                  "java",
                  "jakarta",
                  "javax",
                  "com",
                  "org",
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticThreshold = 9999,
                },
              },
              codeGeneration = {
                toString = {
                  template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                hashCodeEquals = {
                  useJava7Objects = true,
                },
                useBlocks = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
              },
              referencesCodeLens = { enabled = true },
              inlayHints = {
                parameterNames = { enabled = "all" },
              },
            },
          }

          -- Init options
          local init_options = {
            extendedClientCapabilities = extendedClientCapabilities,
          }

          -- On attach function
          local on_attach = function(_, bufnr)
            require("jdtls.setup").add_commands()
            vim.lsp.codelens.refresh()

            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.java" },
              callback = function()
                local _, _ = pcall(vim.lsp.codelens.refresh)
              end,
            })

            -- java_keymaps()
          end

          -- Final configuration
          local config = {
            cmd = cmd,
            root_dir = root_dir,
            settings = settings,
            init_options = init_options,
            on_attach = on_attach,
          }

          -- Start or attach JDTLS
          require("jdtls").start_or_attach(config)
        end

        -- Attach JDTLS when opening Java files
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "java",
          callback = setup_jdtls,
        })

        return true
      end,
    },
  },
}
