if __name__ == '__main__':
    with open(r"egg.asm", 'r') as file_in:
        lines = file_in.readlines()
        file_out = open(r"hex.txt", 'w')
        code_out = open(r"egg.code", 'w')
        for line in lines:
            if len(line) < 1:
                continue
            if line[0] != ' ':
                code_out.write(line[10:-3] + ':\n')
                continue
            file_out.write(line[16:24] + '\n')
            code_out.write(line[32:-1] + '\n')

        file_out.close()
