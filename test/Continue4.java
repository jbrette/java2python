class Continue4 {
    public static void main(String[] args) {
        int i = 0;
        outer:
        while (i < 4) {
            i++;
            int j = 0;
            while (j < 4) {
                j++;
                if (j == 2) {
                    continue outer;
                }
                System.out.println(i * 10 + j);
            }
            System.out.println(-1);
        }
        System.out.println("done");
    }
}
