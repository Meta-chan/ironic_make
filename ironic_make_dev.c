#include <Windows.h>
#include <string.h>
#include <stdio.h>
#define VERSION 0

//Structures
struct Dependency
{
	const char *name;
	struct Dependency *next;
};

struct Command
{
	const char *command;
	struct Command *next;
};

struct Rule
{
	const char *name;
	struct Dependency *dependencies;
	struct Command *commands;
	struct Rule *next;
};

enum Architecture
{
	arch_no = 0,
	arch_x86,
	arch_amd64
};

enum Compiler
{
	comp_no = 0,
	comp_vs,
	comp_gcc
};

enum Mode
{
	mode_execute,
	mode_help,
	mode_version
};

//Global variables
struct
{
	struct Rule *rules;
	enum Architecture arch;
	enum Compiler comp;
	enum Mode mode;
	unsigned int exit_code;
} g;

//Implementation
bool parse_arguments(int argc, char **argv)
{
	for (int i = 0; i < argc; i++)
	{
		if (strcmp(argv[i], "vs") == 0)
		{
			if (g.comp == comp_no) g.comp = comp_vs;
			else printf("Compiler is specified twice\n");
		}
		else if (strcmp(argv[i], "gcc") == 0)
		{
			if (g.comp == comp_no) g.comp = comp_gcc;
			else printf("Compiler is specified twice\n");
		}
		else if (strcmp(argv[i], "x86") == 0)
		{
			if (g.arch == arch_no) g.arch = arch_x86;
			else printf("Architecture is specified twice\n");
		}
		else if (strcmp(argv[i], "amd64") == 0)
		{
			if (g.arch == arch_no) g.arch = arch_amd64;
			else printf("Architecture is specified twice\n");
		}
		else if (strcmp(argv[i], "version") == 0)
		{
			if (g.comp == comp_no && g.arch == arch_no && g.mode == mode_execute) g.mode = mode_version;
			else printf("Too many argumnets\n");
		}
		else g.mode = mode_help;
	}
	return true;
}

bool read_makefile(void)
{
	enum State
	{
		state_wait_makefile,
		state_wait_target,

		state_wait_command_target,
	};

	FILE *batch = fopen("build.bat", "r");
	if (batch == nullptr) return false;
	State state;
}

bool execute_command(const char *command)
{
	enum State
	{
		state_space_wait_nonspace,
		state_word_wait_space,
		state_dollar_wait_bracket_name,
		state_cbracket_wait_cbracket
	} state = state_space_wait_nonspace;
	char buffer[1024]; 
	unsigned int bi = 0;
	for (unsigned int ci = 0; command[ci] != '\0'; ci++)
	{
		char c = command[ci];
		switch (state)
		{
		case state_space_wait_nonspace:
			if (c != ' ' && c != '\t') {}
			break;
		case state_word_wait_space:
			break;
		case state_dollar_wait_bracket_name:
			break;
		case state_cbracket_wait_cbracket:
			break;
		}
	}
}

bool execute_makefile(void)
{
	
}

int main(int argc, char **argv)
{
	if (!parse_arguments(argc, argv)) return 1;
	if (g.mode == mode_execute)
	{
		if (!read_makefile()) return 1;
		if (!execute_makefile()) return 1;
	}
	else if (g.mode == mode_help)
	{
		printf("Help...\n");
	}
	else
	{
		printf("%i\n", VERSION);
	}
	return 0;
}